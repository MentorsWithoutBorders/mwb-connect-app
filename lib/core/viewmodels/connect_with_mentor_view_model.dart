import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/models/student_certificate.model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/connect_with_mentor_service.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';

class ConnectWithMentorViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final ConnectWithMentorService _connectWithMentorService = locator<ConnectWithMentorService>();
  final GoalsService _goalsService = locator<GoalsService>();
  User? selectedMentor;
  Goal? goal;
  StepModel? lastStepAdded;
  LessonRequestModel? lessonRequest;
  Lesson? nextLesson;
  Lesson? previousLesson;
  StudentCertificate? studentCertificate;

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
  
  Future<void> getCertificateSent() async {
    studentCertificate = await _connectWithMentorService.getCertificateSent();
  }  
  
  bool get shouldStopLessons => nextLesson != null && nextLesson?.shouldStop == true;

  bool get isNextLesson => nextLesson != null && nextLesson?.id != null && nextLesson?.isCanceled != true;

  bool get isLessonRequest => !isNextLesson && lessonRequest != null && lessonRequest?.id != null && lessonRequest?.isCanceled != true;

  String get fieldName => _storageService.fieldName != null ? (_storageService.fieldName as String).toLowerCase() : 'common.remote'.tr();

  DateTime? getCertificateDate() {
    DateTime date = DateTime.now();
    if (_storageService.registeredOn != null) {
      DateTime registeredOn = DateTime.parse(_storageService.registeredOn as String);
      date = Jiffy(registeredOn).add(months: 3).dateTime;
    }
    return date;
  }

  bool shouldShowTrainingCompleted() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    return Utils.getDSTAdjustedDifferenceInDays(now, registeredOn) <= 7 * (AppConstants.studentWeeksTraining + 7);
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
