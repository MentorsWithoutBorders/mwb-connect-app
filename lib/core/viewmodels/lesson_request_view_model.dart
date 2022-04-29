import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
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
  List<LessonNote>? lessonsNotes;
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
      isRecurrent: lessonsNumber > 1 ? true : false,
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
  }

  Future<void> cancelNextLesson({bool? isSingleLesson}) async {
    await _lessonRequestService.cancelNextLesson(nextLesson, isSingleLesson);
    await getNextLesson();
    notifyListeners();
  }

  Future<void> updateLessonRecurrence(DateTime endRecurrenceDateTime) async {
    Lesson lesson = Lesson(
      id: nextLesson?.id,
      isRecurrent: true,
      endRecurrenceDateTime: endRecurrenceDateTime,
    );   
    await _lessonRequestService.updateLessonRecurrence(lesson);
    nextLesson?.isRecurrent = lesson.isRecurrent;
    nextLesson?.endRecurrenceDateTime = endRecurrenceDateTime;
    notifyListeners();
  }    

  Future<void> changeLessonUrl(String meetingUrl) async {
    await _lessonRequestService.changeLessonUrl(nextLesson?.id, meetingUrl);
    nextLesson?.meetingUrl = meetingUrl;
    notifyListeners();
  }  

  Future<void> getPreviousLesson() async {
    previousLesson = await _lessonRequestService.getPreviousLesson();
  }

  Future<void> getLessonsNotes(String studentId) async {
    lessonsNotes = await _lessonRequestService.getLessonsNotes(studentId);
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
    }
  }    

  bool get isLessonRecurrent => nextLesson?.isRecurrent == true && nextLesson?.endRecurrenceDateTime?.difference(nextLesson?.dateTime as DateTime).inDays as int >= 7;

  bool get isNextLesson => nextLesson != null && nextLesson?.id != null && nextLesson?.isCanceled != true;

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
