import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';

class NextLessonStudent {
  CourseMentor? mentor;
  DateTime? lessonDateTime;

  NextLessonStudent({@required this.lessonDateTime});

  NextLessonStudent.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    mentor = _mentorFromJson(json['mentor']);
    lessonDateTime = json['lessonDateTime'] != null ? dateFormat.parseUTC(json['lessonDateTime']).toLocal() : null;
  }

  CourseMentor? _mentorFromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return CourseMentor.fromJson(json);
    }
    return null;
  }
  
  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    return {
      'mentor': mentor?.toJson(),
      'lessonDateTime': lessonDateTime != null ? dateFormat.format(lessonDateTime!.toUtc()) : null
    };
  }  
}