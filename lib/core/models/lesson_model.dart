import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class Lesson {
  String? id;
  List<User>? students;
  User? mentor;
  Subfield? subfield;
  DateTime? dateTime;
  String? meetingUrl;
  DateTime? endRecurrenceDateTime;  
  bool? isCanceled;
  bool shouldStop = false;

  Lesson({this.id, this.students, this.mentor, this.subfield, this.dateTime, this.meetingUrl, this.endRecurrenceDateTime, this.isCanceled, this.shouldStop = false});

  Lesson.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    id = json['id'];
    students = _studentsFromJson(json['students']?.cast<Map<String,dynamic>>());
    mentor = _mentorFromJson(json['mentor']);
    subfield = _subfieldFromJson(json['subfield']);
    dateTime = json['dateTime'] != null ? dateFormat.parseUTC(json['dateTime']).toLocal() : null;
    meetingUrl = json['meetingUrl'] ?? '';    
    endRecurrenceDateTime = json['endRecurrenceDateTime'] != null ? dateFormat.parseUTC(json['endRecurrenceDateTime']).toLocal() : null;
    isCanceled = json['isCanceled'];
    shouldStop = json['shouldStop'] ?? false;
  }

  List<User> _studentsFromJson(List<Map<String, dynamic>>? json) {
    final List<User> studentsList = [];
    if (json != null) {    
      for (int i = 0; i < json.length; i++) {
        studentsList.add(User.fromJson(json[i]));
      }
    }
    return studentsList;
  }  

  User? _mentorFromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return User.fromJson(json);
    }
    return null;
  }    

  Subfield? _subfieldFromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return Subfield.fromJson(json);
    }
    return null;
  }    

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    return {
      'id': id,
      'student': _studentsToJson(students),
      'mentor': mentor?.toJson(),
      'subfield': subfield?.toJson(),
      'dateTime': dateTime != null ? dateFormat.format(dateTime!.toUtc()) : null,
      'meetingUrl': meetingUrl,
      'endRecurrenceDateTime': endRecurrenceDateTime != null ? dateFormat.format(endRecurrenceDateTime!.toUtc()) : null,
      'isCanceled': isCanceled
    };
  }

  List<Map<String, dynamic>> _studentsToJson(List<User>? students) {
    List<Map<String,dynamic>> studentsList = [];
    if (students != null) {
      for (int i = 0; i < students.length; i++) {
        studentsList.add(students[i].toJson());
      }
    }
    return studentsList;
  }  
}