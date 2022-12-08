import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';

class CourseModel {
  String? id;
  CourseType? type;
  List<CourseMentor>? mentors;
  List<CourseStudent>? students;
  DateTime? startDateTime;
  bool? isCanceled;

  CourseModel({this.id, this.type, this.mentors, this.students, this.startDateTime, this.isCanceled});

  CourseModel.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    id = json['id'];
    type = _courseTypeFromJson(json['type']);
    mentors = _mentorsFromJson(json['mentors']?.cast<Map<String,dynamic>>());
    students = _studentsFromJson(json['students']?.cast<Map<String,dynamic>>());
    startDateTime = json['startDateTime'] != null ? dateFormat.parseUTC(json['startDateTime']).toLocal() : null;
    isCanceled = json['isCanceled'];
  }

  List<CourseMentor> _mentorsFromJson(List<Map<String, dynamic>>? json) {
    final List<CourseMentor> mentorsList = [];
    if (json != null) {    
      for (int i = 0; i < json.length; i++) {
        mentorsList.add(CourseMentor.fromJson(json[i]));
      }
    }
    return mentorsList;
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

  CourseType? _courseTypeFromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return CourseType.fromJson(json);
    }
    return null;
  }    

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    return {
      'id': id,
      'type': type?.toJson(),
      'mentors': _mentorsToJson(mentors),
      'students': _studentsToJson(students),
      'startDateTime': startDateTime != null ? dateFormat.format(startDateTime!.toUtc()) : null,
      'isCanceled': isCanceled
    };
  }

  List<Map<String, dynamic>> _mentorsToJson(List<CourseMentor>? mentors) {
    List<Map<String,dynamic>> mentorsList = [];
    if (mentors != null) {
      for (int i = 0; i < mentors.length; i++) {
        mentorsList.add(mentors[i].toJson());
      }
    }
    return mentorsList;
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