import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
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
  Goal goal;
  StepModel lastStepAdded;
  int quizNumber;
  LessonRequestModel lessonRequest;
  Lesson nextLesson;
  Lesson previousLesson;
  List<Skill> mentorSkills;
  bool _shouldReload = false;

  Future<void> getGoal() async {
    List<Goal> goals = await _goalsService.getGoals();
    if (goals.length > 0) {
      goal = goals[0];
    }
  }
  
  Future<void> getLastStepAdded() async {
    lastStepAdded = await _connectWithMentorService.getLastStepAdded();
  }

  Future<int> getQuizNumber() async {
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
    await _connectWithMentorService.cancelLessonRequest(lessonRequest.id);
    lessonRequest.isCanceled = true;
    notifyListeners();
  } 
  
  Future<void> getNextLesson() async {
    nextLesson = await _connectWithMentorService.getNextLesson();
  }

  Future<void> cancelNextLesson({bool isSingleLesson}) async {
    await _connectWithMentorService.cancelNextLesson(nextLesson, isSingleLesson);
    await getNextLesson();
    notifyListeners();
  }

  Future<void> getPreviousLesson() async {
    previousLesson = await _connectWithMentorService.getPreviousLesson();
  }  
  
  Future<void> getMentorSkills() async {
    await getPreviousLesson();
    mentorSkills = await _connectWithMentorService.getMentorSkills(previousLesson.mentor.id, previousLesson.subfield.id);
  }
  
  Future<void> addSkills(List<bool> selectedSkills) async {
    List<String> skillIds = [];
    for (int i = 0; i < selectedSkills.length; i++) {
      if (selectedSkills[i]) {
        skillIds.add(mentorSkills[i].id);
      }
    }
    await _connectWithMentorService.addSkills(skillIds, previousLesson.subfield.id);
  }

  Future<void> setMentorPresence(bool isMentorPresent) async {
    await _connectWithMentorService.setMentorPresence(previousLesson.id, isMentorPresent);
  }

  bool get shouldShowTraining => getShouldShowQuizzes() || getShouldShowAddStep();

  bool get isNextLesson => nextLesson != null && nextLesson.id != null && nextLesson.isCanceled != true;

  bool get isLessonRequest => !isNextLesson && lessonRequest != null && lessonRequest.id != null && lessonRequest.isCanceled != true;

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
    if (nextDeadline.difference(lastStepAdded.dateTime).inDays < 7) {
      return false;
    } else {
      return true;
    }
  }  

  DateTime getCertificateDate() {
    DateTime registeredOn = DateTime.parse(_storageService.registeredOn);
    registeredOn = Utils.resetTime(registeredOn);
    DateTime date;
    if (_storageService.registeredOn != null) {
      date = Jiffy(registeredOn).add(months: 3).dateTime;
    }
    return date;
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

  bool shouldReceiveCertificate() {
    DateTime certificateDate = Utils.resetTime(getCertificateDate());
    DateTime deadLine = Utils.resetTime(getNextDeadline());
    return certificateDate.difference(deadLine).inDays <= 0;
  }

  DateTime getCorrectEndRecurrenceDate() {
    int days = 0;
    if (isNextLesson) {
      days = nextLesson.endRecurrenceDateTime.difference(nextLesson.dateTime).inDays;
      if (days % 7 != 0) {
        days = days - days % 7;
      }
    }
    return Jiffy(nextLesson.dateTime).add(days: days).dateTime;
  }

  bool get shouldReload => _shouldReload;
  set shouldReload(bool reload) {
    _shouldReload = reload;
    if (shouldReload) {
      notifyListeners();
    }
  }
}
