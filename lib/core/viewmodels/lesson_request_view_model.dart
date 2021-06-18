import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/services/lesson_request_service.dart';

class LessonRequestViewModel extends ChangeNotifier {
  final LessonRequestService _lessonRequestService = locator<LessonRequestService>();
  LessonRequestModel lessonRequest;
  Lesson nextLesson;
  Lesson previousLesson;
  List<Skill> skills;

  Future<void> getLessonRequest() async {
    lessonRequest = await _lessonRequestService.getLessonRequest();
  }

  Future<void> acceptLessonRequest(String meetingUrl) async {
    nextLesson = await _lessonRequestService.acceptLessonRequest(lessonRequest.id, meetingUrl);
    notifyListeners();
  }  

  Future<void> rejectLessonRequest() async {
    await _lessonRequestService.rejectLessonRequest(lessonRequest.id);
    lessonRequest.isRejected = true;
    notifyListeners();
  }
  
  Future<void> getNextLesson() async {
    nextLesson = await _lessonRequestService.getNextLesson();
  }

  Future<void> cancelNextLesson() async {
    await _lessonRequestService.cancelNextLesson(nextLesson.id);
    nextLesson.isCanceled = true;
    notifyListeners();
  }

  Future<void> getPreviousLesson() async {
    previousLesson = await _lessonRequestService.getPreviousLesson();
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
    await _lessonRequestService.addStudentSkills(previousLesson.student.id, previousLesson.subfield.id, skillIds);
  }

  Future<void> setStudentPresence(bool isStudentPresent) async {
    await _lessonRequestService.setStudentPresence(previousLesson.id, isStudentPresent);
  }

  bool getIsNextLesson() {
    return nextLesson.id != null && nextLesson.isCanceled != true;
  }

  bool getIsLessonRequest() {
    return !getIsNextLesson() && lessonRequest.id != null && lessonRequest.isRejected != true;
  }  

}
