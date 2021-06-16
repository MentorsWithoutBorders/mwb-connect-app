import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class Lesson {
  String id;
  User student;
  User mentor;
  Subfield subfield;
  DateTime dateTime;
  String meetingUrl;
  bool isStudentPresent;
  bool isMentorPresent;
  bool isCanceled;

  Lesson({this.id, this.student, this.mentor, this.subfield, this.dateTime, this.meetingUrl, this.isStudentPresent, this.isMentorPresent, this.isCanceled});

  Lesson.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    id = json['id'];
    student = _userFromJson(json['student']);
    mentor = _userFromJson(json['mentor']);
    subfield = _subfieldFromJson(json['subfield']);
    dateTime = json['dateTime'] != null ? dateFormat.parse(json['dateTime']) : null;
    meetingUrl = json['meetingUrl'] ?? '';    
    isStudentPresent = json['isStudentPresent'];
    isMentorPresent = json['isMentorPresent'];
    isCanceled = json['isCanceled'];
  }

  User _userFromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    User user = User.fromJson(json);
    return user;
  }    

  Subfield _subfieldFromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Subfield subfield = Subfield.fromJson(json);
    return subfield;
  }    

  Map<String, Object> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat);     
    return {
      'id': id,
      'student': student?.toJson(),
      'mentor': mentor?.toJson(),
      'subfield': subfield?.toJson(),
      'dateTime': dateTime != null ? dateFormat.format(dateTime) : null,
      'meetingUrl': meetingUrl,
      'isStudentPresent': isStudentPresent,
      'isMentorPresent': isMentorPresent,
      'isCanceled': isCanceled
    };
  }
}