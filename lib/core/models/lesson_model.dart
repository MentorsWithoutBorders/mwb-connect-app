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
  bool? isRecurrent;
  bool? isRecurrenceDateSelected;
  DateTime? endRecurrenceDateTime;  
  bool? isMentorPresent;
  bool? isCanceled;

  Lesson({this.id, this.students, this.mentor, this.subfield, this.dateTime, this.meetingUrl, this.isRecurrent, this.isRecurrenceDateSelected, this.endRecurrenceDateTime, this.isMentorPresent, this.isCanceled});

  Lesson.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    id = json['id'];
    students = _studentsFromJson(json['students']?.cast<Map<String,dynamic>>());
    mentor = _mentorFromJson(json['mentor']);
    subfield = _subfieldFromJson(json['subfield']);
    dateTime = json['dateTime'] != null ? dateFormat.parseUTC(json['dateTime']).toLocal() : null;
    meetingUrl = json['meetingUrl'] ?? '';    
    isRecurrent = json['isRecurrent'];
    isRecurrenceDateSelected = json['isRecurrenceDateSelected'];
    endRecurrenceDateTime = json['endRecurrenceDateTime'] != null ? dateFormat.parseUTC(json['endRecurrenceDateTime']).toLocal() : null;
    isMentorPresent = json['isMentorPresent'];
    isCanceled = json['isCanceled'];
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
  }    

  Subfield? _subfieldFromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return Subfield.fromJson(json);
    }
  }    

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat);
    return {
      'id': id,
      'student': _studentsToJson(students),
      'mentor': mentor?.toJson(),
      'subfield': subfield?.toJson(),
      'dateTime': dateTime != null ? dateFormat.format(dateTime!.toUtc()) : null,
      'meetingUrl': meetingUrl,
      'isRecurrent': isRecurrent,
      'isRecurrenceDateSelected': isRecurrent != null && isRecurrent == true ? isRecurrenceDateSelected : null,
      'endRecurrenceDateTime': isRecurrent != null && isRecurrent == true && endRecurrenceDateTime != null ? dateFormat.format(endRecurrenceDateTime!.toUtc()) : null,
      'isMentorPresent': isMentorPresent,
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