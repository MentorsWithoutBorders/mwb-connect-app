import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/connect_with_mentor_service.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';

class ConnectWithMentorViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final ConnectWithMentorService _connectWithMentorService = locator<ConnectWithMentorService>();
  final String defaultLocale = Platform.localeName;
  StepModel lastStepAdded;
  LessonRequestModel lessonRequest;
  Lesson nextLesson;
  List<Skill> skills;

  Future<void> getLastStepAdded() async {
    lastStepAdded = await _connectWithMentorService.getLastStepAdded();
  }
  
  Future<void> getLessonRequest() async {
    lessonRequest = await _connectWithMentorService.getLessonRequest();
  }
  
  Future<void> getNextLesson() async {
    nextLesson = await _connectWithMentorService.getNextLesson();
  }

  Future<List<Skill>> getSkills() async {
    skills = await _connectWithMentorService.getSkills();
  }  

  DateTime getCertificateDate() {
    DateTime date;
    if (_storageService.registeredOn != null) {
      date = Jiffy(DateTime.parse(_storageService.registeredOn)).add(months: 3).dateTime;
    }
    return date;
  }

  DateTime getDeadline() {
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn));
    DateTime dateLastStepAdded = Utils.resetTime(lastStepAdded.dateTime);
    Jiffy deadline;
    Jiffy now = Jiffy(Utils.resetTime(DateTime.now()));
    int i = 1;
    bool found = false;
    while (!found) {
      deadline = Jiffy(registeredOn).add(weeks: i);
      if (deadline.dateTime.difference(dateLastStepAdded).inDays > 7 ||
          deadline.isSameOrAfter(now, Units.DAY)) {
        found = true;
      } else {
        i++;
      }
    }
    if (deadline.dateTime.difference(dateLastStepAdded).inDays < 7) {
      deadline = Jiffy(deadline).add(weeks: 1);
    }
    return deadline.dateTime;
  }

  bool isOverdue() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime deadLine = Utils.resetTime(getDeadline());
    return now.difference(deadLine).inDays > 0;
  }

  bool shouldReceiveCertificate() {
    DateTime certificateDate = Utils.resetTime(getCertificateDate());
    DateTime deadLine = Utils.resetTime(getDeadline());
    return certificateDate.difference(deadLine).inDays <= 0;
  }

}
