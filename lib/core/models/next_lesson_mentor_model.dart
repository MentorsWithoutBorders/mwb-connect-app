import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class NextLessonMentor {
  DateTime? lessonDateTime;
  List<CourseStudent>? students;

  NextLessonMentor({@required this.lessonDateTime, @required this.students});

  NextLessonMentor.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    lessonDateTime = json['lessonDateTime'] != null ? dateFormat.parseUTC(json['lessonDateTime']).toLocal() : null;
    students = _studentsFromJson(json['students']?.cast<Map<String,dynamic>>());
  }

  List<CourseStudent> _studentsFromJson(List<Map<String, dynamic>>? json) {
    final List<CourseStudent> studentsList = [];
    if (json != null) {    
      for (int i = 0; i < json.length; i++) {
        studentsList.add(CourseStudent.fromJson(json[i]));
      }
    }
    return studentsList;
  }   

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    return {
      'lessonDateTime': lessonDateTime != null ? dateFormat.format(lessonDateTime!.toUtc()) : null,
      'students': _studentsToJson(students),
    };
  }

  List<Map<String, dynamic>> _studentsToJson(List<CourseStudent>? students) {
    List<Map<String,dynamic>> studentsList = [];
    if (students != null) {
      for (int i = 0; i < students.length; i++) {
        studentsList.add(students[i].toJson());
      }
    }
    return studentsList;
  }   
}
