import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
import 'package:mwb_connect_app/utils/lesson_recurrence_type.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/lesson_note_model.dart';
import 'package:mwb_connect_app/core/models/guide_tutorial_model.dart';
import 'package:mwb_connect_app/core/models/guide_recommendation_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';
import 'package:mwb_connect_app/core/services/lesson_request_service.dart';
import 'package:mwb_connect_app/core/services/quizzes_service.dart';

class LessonRequestViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final LessonRequestService _lessonRequestService = locator<LessonRequestService>();
  final QuizzesService _quizzesService = locator<QuizzesService>();
  final GoalsService _goalsService = locator<GoalsService>();
  Goal goal;
  StepModel lastStepAdded;
  int quizNumber;  
  LessonRequestModel lessonRequest;
  String quizzes;
  Lesson nextLesson;
  Lesson previousLesson;
  List<Skill> skills;
  List<LessonNote> lessonsNotes;
  List<GuideTutorial> guideTutorials;
  List<GuideRecommendation> guideRecommendations;
  bool _shouldUnfocus = false;
  bool shouldShowExpired = false;
  bool shouldShowCanceled = false;

  Future<void> getGoal() async {
    List<Goal> goals = await _goalsService.getGoals();
    if (goals.isNotEmpty) {
      setGoal(goals[0]);
    } else {
      setGoal(null);
    }
  }

  void setGoal(Goal goal) {
    this.goal = goal;
  }  

  Future<void> getLastStepAdded() async {
    lastStepAdded = await _lessonRequestService.getLastStepAdded();
  }

  Future<void> getQuizNumber() async {
    quizNumber = await _quizzesService.getQuizNumber();
  }  

  Future<void> getLessonRequest() async {
    lessonRequest = await _lessonRequestService.getLessonRequest();
    if (lessonRequest != null && lessonRequest.id != null) {
      if (lessonRequest.isExpired != null && lessonRequest.isExpired) {
        if (lessonRequest.wasExpiredShown == null || lessonRequest.wasExpiredShown != null && !lessonRequest.wasExpiredShown) {
          shouldShowExpired = true;
          await _lessonRequestService.updateLessonRequest(lessonRequest.id, LessonRequestModel(wasExpiredShown: true));
        }
        lessonRequest = null;
      } else if (lessonRequest.isCanceled != null && lessonRequest.isCanceled) {
        if (lessonRequest.wasCanceledShown == null || lessonRequest.wasCanceledShown != null && !lessonRequest.wasCanceledShown) {
          shouldShowCanceled = true;
          await _lessonRequestService.updateLessonRequest(lessonRequest.id, LessonRequestModel(wasCanceledShown: true));
        }
        lessonRequest = null;
      }
    }
  }

  String addLessonRequestId(String existingIds, String newId) {
    List<String> ids = existingIds != null ? existingIds.split(', ') : [];
    if (ids.isEmpty || !ids.contains(newId)) {
      ids.add(newId);
    }
    return ids.join(', ');
  }

  Future<void> acceptLessonRequest(String meetingUrl, BuildContext context) async {
    nextLesson.meetingUrl = meetingUrl;
    Lesson acceptedLessonRequest = await _lessonRequestService.acceptLessonRequest(lessonRequest.id, nextLesson);
    if (acceptedLessonRequest != null && acceptedLessonRequest.id != null) {
      nextLesson = acceptedLessonRequest;
      lessonRequest.id = null;
      notifyListeners();      
    } else {
      Phoenix.rebirth(context);
    }
  }  

  Future<void> rejectLessonRequest() async {
    await _lessonRequestService.rejectLessonRequest(lessonRequest.id);
    lessonRequest.isRejected = true;
    notifyListeners();
  }
  
  Future<void> getNextLesson() async {
    nextLesson = await _lessonRequestService.getNextLesson();
  }

  Future<void> cancelNextLesson({bool isSingleLesson}) async {
    await _lessonRequestService.cancelNextLesson(nextLesson, isSingleLesson);
    await getNextLesson();
    notifyListeners();
  }

  Future<void> updateLessonRecurrence() async {
    if (isNextLesson) {
      Lesson lesson = Lesson(
        id: nextLesson.id,
        isRecurrent: nextLesson.isRecurrent,
        endRecurrenceDateTime: nextLesson.endRecurrenceDateTime,
        isRecurrenceDateSelected: nextLesson.isRecurrenceDateSelected
      );
      if (!lesson.isRecurrent) {
        lesson.isRecurrent = true;
        lesson.endRecurrenceDateTime = nextLesson.dateTime;
      }    
      await _lessonRequestService.updateLessonRecurrence(lesson);
    }
  }    

  Future<void> changeLessonUrl(String meetingUrl) async {
    await _lessonRequestService.changeLessonUrl(nextLesson.id, meetingUrl);
    nextLesson.meetingUrl = meetingUrl;
    notifyListeners();
  }  

  Future<void> getPreviousLesson() async {
    previousLesson = await _lessonRequestService.getPreviousLesson();
  }

  Future<void> getLessonsNotes(String studentId) async {
    lessonsNotes = await _lessonRequestService.getLessonsNotes(studentId);
  }
  
  Future<void> getGuideTutorials() async {
    guideTutorials = await _lessonRequestService.getGuideTutorials(nextLesson.id);
  }

  Future<void> getGuideRecommendations() async {
    guideRecommendations = await _lessonRequestService.getGuideRecommendations(nextLesson.id);
  }    

  Future<void> addStudentsLessonNotes(String text) async {
    LessonNote lessonNote = LessonNote(text: text);
    if (previousLesson != null && previousLesson.id != null) {
      await _lessonRequestService.addStudentsLessonNotes(previousLesson.id, lessonNote);
    }
  }    

  Future<void> getSkills() async {
    await getPreviousLesson();
    skills = await _lessonRequestService.getSkills(previousLesson.subfield.id);
  }
  
  Future<void> addStudentSkills(List<bool> selectedSkills) async {
    List<String> skillIds = [];
    for (int i = 0; i < selectedSkills.length; i++) {
      if (selectedSkills[i]) {
        skillIds.add(skills[i].id);
      }
    }
    if (previousLesson != null && previousLesson.id != null) {
      await _lessonRequestService.addStudentSkills(previousLesson.id, skillIds);
    }
  }

  bool get shouldShowTraining => getShouldShowQuizzes() || getShouldShowAddStep();

  bool get isNextLesson => nextLesson != null && nextLesson.id != null && nextLesson.isCanceled != true;

  bool get isLessonRequest => !isNextLesson && lessonRequest != null && lessonRequest.id != null && lessonRequest.isRejected != true;
  
  bool checkValidUrl(String url) {
    return Uri.parse(url).isAbsolute && (url.contains('meet') || url.contains('zoom'));
  }

  void refreshTrainingInfo() {   
    if (_storageService.quizNumber != null) {
      quizNumber = _storageService.quizNumber;
      _storageService.quizNumber = null;
    }
    if (_storageService.lastStepAddedId != null) {
      lastStepAdded.id = _storageService.lastStepAddedId;
      lastStepAdded.dateTime = DateTime.now();
      _storageService.lastStepAddedId = null;
    }    
    notifyListeners();
  }

  String getQuizzesLeft() {
    int weeklyCount = _storageService.quizzesMentorWeeklyCount;
    int quizzesNumber = weeklyCount - ((quizNumber - 1) % weeklyCount);
    String quizzesPlural = plural('quiz', quizzesNumber);
    String quizzesLeft = quizzesNumber.toString();
    if (quizzesNumber < weeklyCount) {
      quizzesLeft += ' ' + 'common.more'.tr();
    }
    quizzesLeft += ' ' + quizzesPlural;
    return quizzesLeft;
  }

  bool getShouldShowQuizzes() {
    if (quizNumber != 0) {
      return true;
    } else {
      return false;
    }
  }  

  bool getShouldShowAddStep() {
    DateTime nextDeadline = getNextDeadline();
    if (lastStepAdded.id != null && nextDeadline.difference(lastStepAdded.dateTime).inDays < 7) {
      return false;
    } else {
      return true;
    }
  }

  void initLessonRecurrence() {
    if (nextLesson == null || nextLesson.id == null) {
      bool isRecurrent = nextLesson.isRecurrent == null ? false : nextLesson.isRecurrent;
      nextLesson = Lesson(isRecurrent: isRecurrent);
    } else if (nextLesson.isRecurrent == null || nextLesson.isRecurrent && nextLesson.endRecurrenceDateTime.difference(nextLesson.dateTime).inDays < 7) {
      nextLesson.isRecurrent = false;
    }
  }

  void setEndRecurrenceDate({DateTime picked, int lessonsNumber}) {
    if (picked != null) {
      nextLesson.endRecurrenceDateTime = picked;
      if (isLessonRequest) {
        nextLesson.endRecurrenceDateTime = nextLesson.endRecurrenceDateTime.copyWith(hour: lessonRequest.lessonDateTime.hour);
      } else if (isNextLesson) {
        nextLesson.endRecurrenceDateTime = nextLesson.endRecurrenceDateTime.copyWith(hour: nextLesson.dateTime.hour);
      }      
    } else {
      if (isLessonRequest) {
        int duration = (lessonsNumber - 1) * 7;
        nextLesson.endRecurrenceDateTime = lessonRequest.lessonDateTime.add(Duration(days: duration));
      } else if (isNextLesson) {
        int duration = (lessonsNumber - 1) * 7;
        nextLesson.endRecurrenceDateTime = nextLesson.dateTime.add(Duration(days: duration));
      }
    }
  }

  void setLessonRecurrenceType(LessonRecurrenceType recurrenceType) {
    if (recurrenceType == LessonRecurrenceType.date) {
      nextLesson.isRecurrenceDateSelected = true;
    } else if (recurrenceType == LessonRecurrenceType.lessons) {
      nextLesson.isRecurrenceDateSelected = false;
    }
  }

  LessonRecurrenceType getLessonRecurrenceType() {
    if (nextLesson.isRecurrenceDateSelected != null) {
      if (nextLesson.isRecurrenceDateSelected) {
        return LessonRecurrenceType.date;
      } else {
        return LessonRecurrenceType.lessons;
      }
    } else {
      return LessonRecurrenceType.lessons;
    }
  }  

  DateTime getMinRecurrenceDate() {
    DateTime minRecurrenceDate;
    if (isLessonRequest) {
      minRecurrenceDate = lessonRequest.lessonDateTime.add(Duration(days: 7));
    } else if (isNextLesson) {
      minRecurrenceDate = nextLesson.dateTime.add(Duration(days: 7));
    }
    return minRecurrenceDate;
  }

  DateTime getMaxRecurrenceDate() {
    DateTime maxRecurrenceDate;
    int maxDays = AppConstants.maxLessonsNumberRecurrence * 7 - 7;
    if (isLessonRequest) {
      maxRecurrenceDate = lessonRequest.lessonDateTime.add(Duration(days: maxDays));
    } else if (isNextLesson) {
      maxRecurrenceDate = nextLesson.dateTime.add(Duration(days: maxDays));
    }
    return maxRecurrenceDate;
  }  

  int calculateLessonsNumber(DateTime endRecurrenceDate) {
    int lessonsNumber = AppConstants.minLessonsNumberRecurrence;
    if (endRecurrenceDate != null) {
      if (isLessonRequest) {
        lessonsNumber = endRecurrenceDate.difference(Utils.resetTime(lessonRequest.lessonDateTime)).inDays ~/ 7 + 1;
      } else if (isNextLesson) {
        lessonsNumber = endRecurrenceDate.difference(Utils.resetTime(nextLesson.dateTime)).inDays ~/ 7 + 1;
      }
    }
    return lessonsNumber;
  }

  DateTime getNextDeadline() {
    DateTime registeredOn = DateTime.parse(_storageService.registeredOn);
    registeredOn = Utils.resetTime(registeredOn);
    Jiffy deadline;
    if (lastStepAdded != null && lastStepAdded.dateTime != null) {
      DateTime lastStepAddedDateTime = lastStepAdded.dateTime;
      lastStepAddedDateTime = Utils.resetTime(lastStepAddedDateTime);
      Jiffy now = Jiffy(Utils.resetTime(DateTime.now()));
      int i = 1;
      bool found = false;
      while (!found) {
        deadline = Jiffy(registeredOn).add(weeks: i);
        if (deadline.dateTime.difference(lastStepAddedDateTime).inDays > 7 ||
            deadline.isSameOrAfter(now, Units.DAY)) {
          found = true;
        } else {
          i++;
        }
      }
    } else {
      deadline = Jiffy(registeredOn).add(weeks: 1);
    }
    return deadline.dateTime;
  }

  bool isOverdue() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime deadLine = Utils.resetTime(getNextDeadline());
    return now.difference(deadLine).inDays > 0;
  }
  
  void setIsLessonRecurrent() {
    nextLesson.isRecurrent = !nextLesson.isRecurrent;
    notifyListeners();
  }   

  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }
}
