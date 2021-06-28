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
  bool _shouldUnfocus = false;

  Future<void> getLessonRequest() async {
    lessonRequest = await _lessonRequestService.getLessonRequest();
  }

  Future<void> acceptLessonRequest(String meetingUrl) async {
    nextLesson = await _lessonRequestService.acceptLessonRequest(lessonRequest.id, meetingUrl);
    lessonRequest = null;
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

  Future<void> changeLessonUrl(String meetingUrl) async {
    await _lessonRequestService.changeLessonUrl(nextLesson.id, meetingUrl);
    nextLesson.meetingUrl = meetingUrl;
    notifyListeners();
  }  

  Future<void> getPreviousLesson() async {
    previousLesson = await _lessonRequestService.getPreviousLesson();
  }
  
  bool get isNextLesson => nextLesson != null && nextLesson.id != null && nextLesson.isCanceled != true;

  bool get isLessonRequest => !isNextLesson && lessonRequest != null && lessonRequest.id != null && lessonRequest.isRejected != true;
  
  bool checkValidUrl(String url) {
    return Uri.parse(url).isAbsolute && (url.contains('meet') || url.contains('zoom'));
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
    await _lessonRequestService.addStudentSkills(previousLesson.students[0].id, previousLesson.subfield.id, skillIds);
  }

  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }  
}
