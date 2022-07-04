import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/lesson_recurrence_result_model.dart';
import 'package:mwb_connect_app/core/models/lesson_note_model.dart';
import 'package:mwb_connect_app/core/models/guide_tutorial_model.dart';
import 'package:mwb_connect_app/core/models/guide_recommendation_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';
import 'package:mwb_connect_app/core/services/lesson_request_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class LessonRequestViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final LessonRequestService _lessonRequestService = locator<LessonRequestService>();
  final GoalsService _goalsService = locator<GoalsService>();
  final LoggerService _loggerService = locator<LoggerService>();
  Goal? goal;
  LessonRequestModel? lessonRequest;
  int _lessonsNumber = 1;
  String? quizzes;
  Lesson? nextLesson;
  Lesson? previousLesson;
  Map<String, List<LessonNote>> studentsLessonsNotes = Map();
  List<GuideTutorial>? guideTutorials;
  List<GuideRecommendation>? guideRecommendations;
  bool _shouldUnfocus = false;
  bool shouldShowExpired = false;
  bool shouldShowCanceled = false;

  Future<void> getGoal() async {
    List<Goal> goals = await _goalsService.getGoals();
    if (goals.isNotEmpty) {
      setGoal(goals[0]);
    } else {
      addLogEntry('setting goal to null in getGoal()');
      setGoal(null);
    }
  }

  void setGoal(Goal? goal) {
    this.goal = goal;
  }

  Future<void> getLessonRequest() async {
    lessonRequest = await _lessonRequestService.getLessonRequest();
    if (lessonRequest != null && lessonRequest?.id != null) {
      if (lessonRequest?.isExpired != null && lessonRequest?.isExpired == true) {
        if (lessonRequest?.wasExpiredShown == null || lessonRequest?.wasExpiredShown != null && lessonRequest?.wasExpiredShown == false) {
          shouldShowExpired = true;
          await _lessonRequestService.updateLessonRequest(lessonRequest?.id, LessonRequestModel(wasExpiredShown: true));
        }
        lessonRequest = null;
      } else if (lessonRequest?.isCanceled != null && lessonRequest?.isCanceled == true) {
        if (lessonRequest?.wasCanceledShown == null || lessonRequest?.wasCanceledShown != null && lessonRequest?.wasCanceledShown == false) {
          shouldShowCanceled = true;
          await _lessonRequestService.updateLessonRequest(lessonRequest?.id, LessonRequestModel(wasCanceledShown: true));
        }
        lessonRequest = null;
      }
    }
  }

  String addLessonRequestId(String? existingIds, String newId) {
    List<String> ids = existingIds != null ? existingIds.split(', ') : [];
    if (ids.isEmpty || !ids.contains(newId)) {
      ids.add(newId);
    }
    return ids.join(', ');
  }

  Future<void> acceptLessonRequest(String meetingUrl, BuildContext context) async {
    DateTime lessonDateTime = lessonRequest?.lessonDateTime as DateTime;
    DateTime endRecurrenceDateTime = lessonDateTime.add(Duration(days: (lessonsNumber - 1) * 7));    
    Lesson lesson = Lesson(
      endRecurrenceDateTime: endRecurrenceDateTime,
      meetingUrl: meetingUrl
    );     
    Lesson acceptedLessonRequest = await _lessonRequestService.acceptLessonRequest(lessonRequest?.id, lesson);
    if (acceptedLessonRequest.id != null) {
      nextLesson = acceptedLessonRequest;
      lessonRequest?.id = null;
      notifyListeners();      
    } else {
      Phoenix.rebirth(context);
    }
  }  

  Future<void> rejectLessonRequest() async {
    await _lessonRequestService.rejectLessonRequest(lessonRequest?.id);
    lessonRequest?.isRejected = true;
    notifyListeners();
  }
  
  Future<void> getNextLesson() async {
    nextLesson = await _lessonRequestService.getNextLesson();
    studentsLessonsNotes.clear();
    for (User student in nextLesson?.students as List<User>) {
      List<LessonNote> lessonsNotes = await this.getLessonsNotes(student.id as String);
      studentsLessonsNotes.putIfAbsent(student.id as String, () => lessonsNotes);   
    }
  }

  Future<void> cancelNextLesson({bool? isSingleLesson}) async {
    await _lessonRequestService.cancelNextLesson(nextLesson, isSingleLesson);
    await getNextLesson();
    notifyListeners();
  }

  void initLessonRecurrence() {
    lessonsNumber = 1;
  }
  
  DateTime getLessonDateTimeForRecurrence(Lesson? lesson) {
    DateTime lessonDateTime = DateTime.now();
    DateTime now = DateTime.now();
    if (lesson?.endRecurrenceDateTime != null) {
      lessonDateTime = lesson?.endRecurrenceDateTime as DateTime;
    } else {
      lessonDateTime = lesson?.dateTime as DateTime;
    }
    while (now.difference(lessonDateTime).inDays >= 6) {
      lessonDateTime = lessonDateTime.add(Duration(days: 7));
    }
    return lessonDateTime;
  }

  Future<LessonRecurrenceResult> updateLessonRecurrence(Lesson? lesson, DateTime endRecurrenceDateTime) async {
    Lesson lessonData = Lesson(
      id: lesson?.id,
      endRecurrenceDateTime: endRecurrenceDateTime,
    );   
    LessonRecurrenceResult lessonRecurrenceResult = await _lessonRequestService.updateLessonRecurrence(lessonData);
    nextLesson?.endRecurrenceDateTime = endRecurrenceDateTime;
    notifyListeners();
    return lessonRecurrenceResult;
  }    

  Future<void> changeLessonUrl(String meetingUrl) async {
    await _lessonRequestService.changeLessonUrl(nextLesson?.id, meetingUrl);
    nextLesson?.meetingUrl = meetingUrl;
    notifyListeners();
  }  

  Future<void> getPreviousLesson() async {
    previousLesson = await _lessonRequestService.getPreviousLesson();
  }

  Future<List<LessonNote>> getLessonsNotes(String studentId) async {
    return await _lessonRequestService.getLessonsNotes(studentId);
  }
  
  Future<void> getGuideTutorials() async {
    guideTutorials = await _lessonRequestService.getGuideTutorials(nextLesson?.id);
  }

  Future<void> getGuideRecommendations() async {
    guideRecommendations = await _lessonRequestService.getGuideRecommendations(nextLesson?.id);
  }    

  Future<void> addStudentsLessonNotes(String text) async {
    LessonNote lessonNote = LessonNote(text: text);
    if (previousLesson != null && previousLesson?.id != null) {
      await _lessonRequestService.addStudentsLessonNotes(previousLesson?.id, lessonNote);
    } else if (nextLesson != null && nextLesson?.id != null) {
      await _lessonRequestService.addStudentsLessonNotes(nextLesson?.id, lessonNote);
    }
  }    

  bool get isNextLesson => nextLesson != null && nextLesson?.id != null && nextLesson?.isCanceled != true;
  
  bool get isPreviousLesson => previousLesson != null && previousLesson?.id != null && previousLesson?.isCanceled != true;

  bool get isLessonRequest => !isNextLesson && lessonRequest != null && lessonRequest?.id != null && lessonRequest?.isRejected != true;
  
  bool checkValidUrl(String url) {
    return Uri.parse(url).isAbsolute && (url.contains('meet') || url.contains('zoom'));
  }

  bool shouldShowTrainingCompleted() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    return Utils.getDSTAdjustedDifferenceInDays(now, registeredOn) <= 7 * AppConstants.mentorWeeksTraining;
  }
  
  DateTime getCorrectEndRecurrenceDate() {
    int days = 0;
    if (isNextLesson == true && nextLesson?.endRecurrenceDateTime != null && nextLesson?.dateTime != null) {
      days = nextLesson?.endRecurrenceDateTime?.difference(nextLesson?.dateTime as DateTime).inDays as int;
      if (days % 7 != 0) {
        days = days - days % 7;
      }
    }
    return Jiffy(nextLesson?.dateTime).add(days: days).dateTime;
  } 

  String getLessonRecurrenceText(int previousLessonStudentsNumber, int studentsRemaining) {
    if (previousLessonStudentsNumber == 1) {
      return 'lesson_request.student_different_mentor'.tr();
    } else if (previousLessonStudentsNumber > 1) {
      if (studentsRemaining > 0) {
        if (previousLessonStudentsNumber - studentsRemaining == 1) {
          return 'lesson_request.one_student_different_mentor'.tr();
        } else {
          return 'lesson_request.some_students_other_mentors'.tr(args: [(previousLessonStudentsNumber - studentsRemaining).toString()]);
        }
      } else {
        return 'lesson_request.students_other_mentors'.tr();
      }
    } else {
      return 'lesson_request.students_other_mentors'.tr();
    }
  }

  int get lessonsNumber => _lessonsNumber;
  set lessonsNumber(int number) {
    _lessonsNumber = number;
    notifyListeners();
  }

  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }

  void addLogEntry(String text) {
    _loggerService.addLogEntry(text);
  }  
}
