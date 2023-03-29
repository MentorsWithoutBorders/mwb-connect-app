import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class NextLessonMentor {
  DateTime? lessonDateTime;

  NextLessonMentor({@required this.lessonDateTime});

  NextLessonMentor.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    lessonDateTime = json['lessonDateTime'] != null ? dateFormat.parseUTC(json['lessonDateTime']).toLocal() : null;
  }

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    return {
      'lessonDateTime': lessonDateTime != null ? dateFormat.format(lessonDateTime!.toUtc()) : null
    };
  }   
}