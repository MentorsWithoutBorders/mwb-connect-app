import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
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
    nextLesson.meetingUrl = meetingUrl;
    nextLesson = await _lessonRequestService.acceptLessonRequest(lessonRequest.id, nextLesson);
    lessonRequest.id = null;
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

  void initLessonRecurrence() {
    if (nextLesson == null || nextLesson.isRecurrent == null) {
      nextLesson = Lesson(isRecurrent: false, endRecurrenceDateTime: DateTime.now());
    }       
  }

  void setEndRecurrenceDate({DateTime picked, int lessonsNumber}) {
    if (picked != null) {
      nextLesson.endRecurrenceDateTime = picked;
      if (lessonRequest != null) {
        nextLesson.endRecurrenceDateTime = nextLesson.endRecurrenceDateTime.copyWith(hour: lessonRequest.lessonDateTime.hour);
      } else if (nextLesson != null) {
        nextLesson.endRecurrenceDateTime = nextLesson.endRecurrenceDateTime.copyWith(hour: nextLesson.dateTime.hour);
      }      
    } else {
      if (lessonRequest != null) {
        int duration = (lessonsNumber - 1) * 7;
        nextLesson.endRecurrenceDateTime = lessonRequest.lessonDateTime.add(Duration(days: duration));
      } else if (nextLesson != null) {
        int duration = (lessonsNumber - 1) * 7;
        nextLesson.endRecurrenceDateTime = nextLesson.dateTime.add(Duration(days: duration));
      }
    }
  }

  DateTime getMinRecurrenceDate() {
    DateTime minRecurrenceDate;
    if (lessonRequest != null) {
      minRecurrenceDate = lessonRequest.lessonDateTime.add(Duration(days: 7));
    } else if (nextLesson != null) {
      minRecurrenceDate = nextLesson.dateTime.add(Duration(days: 7));
    }
    return minRecurrenceDate;
  }

  DateTime getMaxRecurrenceDate() {
    DateTime maxRecurrenceDate;
    if (lessonRequest != null) {
      maxRecurrenceDate = lessonRequest.lessonDateTime.add(Duration(days: 133));
    } else if (nextLesson != null) {
      maxRecurrenceDate = nextLesson.dateTime.add(Duration(days: 133));
    }
    return maxRecurrenceDate;
  }  

  int calculateLessonsNumber(DateTime endRecurrenceDate) {
    int lessonsNumber = AppConstants.minLessonsNumberRecurrence;
    if (endRecurrenceDate != null) {
      if (lessonRequest != null) {
        lessonsNumber = endRecurrenceDate.difference(Utils.resetTime(lessonRequest.lessonDateTime)).inDays ~/ 7 + 1;
      } else if (nextLesson != null) {
        lessonsNumber = endRecurrenceDate.difference(Utils.resetTime(nextLesson.dateTime)).inDays ~/ 7 + 1;
      }
    }
    return lessonsNumber;
  }
  
  void setIsLessonRecurrent() {
    nextLesson.isRecurrent = !nextLesson.isRecurrent;
    notifyListeners();
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
