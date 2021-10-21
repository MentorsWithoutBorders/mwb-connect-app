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

class ConnectWithMentorViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final ConnectWithMentorService _connectWithMentorService = locator<ConnectWithMentorService>();
  final GoalsService _goalsService = locator<GoalsService>(); 
  Goal? goal;
  StepModel? lastStepAdded;
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

  bool get shouldStopLessons => nextLesson != null && nextLesson?.shouldStop == true;

  bool get isNextLesson => nextLesson != null && nextLesson?.id != null && nextLesson?.isCanceled != true;

  bool get isLessonRequest => !isNextLesson && lessonRequest != null && lessonRequest?.id != null && lessonRequest?.isCanceled != true;

  String get fieldName => _storageService.fieldName != null ? (_storageService.fieldName as String).toLowerCase() : 'common.remote'.tr();

  bool getShouldShowAddStep() {
    DateTime nextDeadline = Utils.getNextDeadline() as DateTime;
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

  bool shouldShowTrainingCompleted() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    return now.difference(registeredOn).inDays <= 7 * AppConstants.studentWeeksTraining;
  }  

  bool shouldReceiveCertificate() {
    DateTime certificateDate = Utils.resetTime(getCertificateDate() as DateTime);
    DateTime deadLine = Utils.resetTime(Utils.getNextDeadline() as DateTime);
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
