import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/connect_with_mentor_service.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';
import 'package:mwb_connect_app/core/services/quizzes_service.dart';

class ConnectWithMentorViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final ConnectWithMentorService _connectWithMentorService = locator<ConnectWithMentorService>();
  final QuizzesService _quizzesService = locator<QuizzesService>();
  final GoalsService _goalsService = locator<GoalsService>(); 
  Goal? goal;
  StepModel? lastStepAdded;
  int? quizNumber;
  LessonRequestModel? lessonRequest;
  Lesson? nextLesson;
  Lesson? previousLesson;
  List<Skill>? mentorSkills;

  Future<void> getGoal() async {
    List<Goal> goals = await _goalsService.getGoals();
    if (goals.isNotEmpty) {
      setGoal(goals[0]);
    } else {
      setGoal(null);
    }
  }

  void setGoal(Goal? goal) {
    this.goal = goal;
  }  
  
  Future<void> getLastStepAdded() async {
    lastStepAdded = await _connectWithMentorService.getLastStepAdded();
  }

  Future<void> getQuizNumber() async {
    quizNumber = await _quizzesService.getQuizNumber();
  }
  
  Future<void> getLessonRequest() async {
    lessonRequest = await _connectWithMentorService.getLessonRequest();
  }

  Future<void> sendLessonRequest() async {
    lessonRequest = await _connectWithMentorService.sendLessonRequest();
    notifyListeners();
  }  

  Future<void> cancelLessonRequest() async {
    await _connectWithMentorService.cancelLessonRequest(lessonRequest?.id);
    lessonRequest?.isCanceled = true;
    notifyListeners();
  } 
  
  Future<void> getNextLesson() async {
    nextLesson = await _connectWithMentorService.getNextLesson();
  }

  Future<void> cancelNextLesson({bool? isSingleLesson}) async {
    await _connectWithMentorService.cancelNextLesson(nextLesson, isSingleLesson);
    await getNextLesson();
    notifyListeners();
  }

  Future<void> getPreviousLesson() async {
    previousLesson = await _connectWithMentorService.getPreviousLesson();
  }  
  
  Future<void> getMentorSkills() async {
    await getPreviousLesson();
    mentorSkills = await _connectWithMentorService.getMentorSkills(previousLesson?.mentor?.id, previousLesson?.subfield?.id);
  }
  
  Future<void> addSkills(List<bool> selectedSkills) async {
    List<String> skillIds = [];
    for (int i = 0; i < selectedSkills.length; i++) {
      if (selectedSkills[i] == true) {
        skillIds.add(mentorSkills?[i].id as String);
      }
    }
    if (previousLesson != null && previousLesson?.subfield != null) {
      await _connectWithMentorService.addSkills(skillIds, previousLesson?.subfield?.id);
    }
  }

  Future<void> setMentorPresence(bool isMentorPresent) async {
    await _connectWithMentorService.setMentorPresence(previousLesson?.id, isMentorPresent);
  }

  bool get shouldShowTraining => getShouldShowQuizzes() || getShouldShowAddStep();

  bool get shouldStopLessons => nextLesson != null && nextLesson?.shouldStop == true;

  bool get isNextLesson => nextLesson != null && nextLesson?.id != null && nextLesson?.isCanceled != true;

  bool get isLessonRequest => !isNextLesson && lessonRequest != null && lessonRequest?.id != null && lessonRequest?.isCanceled != true;

  String get fieldName => _storageService.fieldName != null ? (_storageService.fieldName as String).toLowerCase() : 'common.remote'.tr();

  void refreshTrainingInfo() {
    if (_storageService.quizNumber != null) {
      quizNumber = _storageService.quizNumber;
      _storageService.quizNumber = null;
    }
    if (_storageService.lastStepAddedId != null) {
      lastStepAdded?.id = _storageService.lastStepAddedId;
      lastStepAdded?.dateTime = DateTime.now();
      _storageService.lastStepAddedId = null;
    }    
    notifyListeners();
  }  

  String getQuizzesLeft() {
    int? weeklyCount = _storageService.quizzesMentorWeeklyCount;
    String quizzesLeft = '';
    if (weeklyCount != null && quizNumber != null) {
      int quizzesNumber = weeklyCount - ((quizNumber! - 1) % weeklyCount);
      String quizzesPlural = plural('quiz', quizzesNumber);
      quizzesLeft = quizzesNumber.toString();
      if (quizzesNumber < weeklyCount) {
        quizzesLeft += ' ' + 'common.more'.tr();
      }
      quizzesLeft += ' ' + quizzesPlural;
    }
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
    DateTime nextDeadline = getNextDeadline() as DateTime;
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    int limit = now.difference(registeredOn).inDays > 7 ? 7 : 8;
    if (lastStepAdded?.id != null && nextDeadline.difference(Utils.resetTime(lastStepAdded?.dateTime as DateTime)).inDays < limit) {
      return false;
    } else {
      return true;
    }
  }  

  DateTime? getCertificateDate() {
    DateTime registeredOn = DateTime.parse(_storageService.registeredOn as String);
    registeredOn = Utils.resetTime(registeredOn);
    DateTime? date;
    if (_storageService.registeredOn != null) {
      date = Jiffy(registeredOn).add(months: 3).dateTime;
    }
    return date;
  }

  DateTime? getNextDeadline() {
    Jiffy now = Jiffy(Utils.resetTime(DateTime.now()));
    Jiffy deadline = Jiffy(Utils.resetTime(DateTime.parse(_storageService.registeredOn as String)));
    if (deadline.isSame(now)) {
      deadline.add(weeks: 1);
    } else {
      while (deadline.isBefore(now, Units.DAY)) {
        deadline.add(weeks: 1);
      }
    }
    return deadline.dateTime;
  }

  String getTrainingWeek() {
    Jiffy nextDeadline = Jiffy(getNextDeadline());
    Jiffy date = Jiffy(Utils.resetTime(DateTime.parse(_storageService.registeredOn as String)));
    int weekNumber = 0;
    while (date.isSameOrBefore(nextDeadline, Units.DAY)) {
      date.add(weeks: 1);
      weekNumber++;
    }
    weekNumber--;
    String week = '';
    switch (weekNumber) {
      case 1:
        week = 'numerals.first'.tr();
        break;
      case 2: 
        week = 'numerals.second'.tr();
        break;
      case 3: 
        week = 'numerals.third'.tr();
        break;
      default:
        week = 'numerals.nth'.tr(args: [weekNumber.toString()]);
    }
    return week;
  }

  bool shouldShowTrainingCompleted() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    return now.difference(registeredOn).inDays <= 7 * AppConstants.studentWeeksTraining;
  }  

  bool shouldReceiveCertificate() {
    DateTime certificateDate = Utils.resetTime(getCertificateDate() as DateTime);
    DateTime deadLine = Utils.resetTime(getNextDeadline() as DateTime);
    return certificateDate.difference(deadLine).inDays <= 0;
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
}
