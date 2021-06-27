import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class LessonRequestModel {
  String id;
  User student;
  User mentor;
  Subfield subfield;
  DateTime lessonDateTime;
  bool isCanceled;
  bool isRejected;

  LessonRequestModel({this.id, this.student, this.mentor, this.subfield, this.lessonDateTime, this.isCanceled, this.isRejected});

  LessonRequestModel.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    id = json['id'];
    student = _userFromJson(json['student']);
    mentor = _userFromJson(json['mentor']);
    subfield = _subfieldFromJson(json['subfield']);
    lessonDateTime = json['lessonDateTime'] != null ? dateFormat.parse(json['lessonDateTime'], true) : null;
    isCanceled = json['isCanceled'];
    isRejected = json['isRejected'];
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
      'student': student.toJson(),
      'mentor': mentor.toJson(),
      'subfield': subfield.toJson(),
      'lessonDateTime': lessonDateTime != null ? dateFormat.format(lessonDateTime) : null,
      'isCanceled': isCanceled,
      'isRejected': isRejected
    };
  }
}