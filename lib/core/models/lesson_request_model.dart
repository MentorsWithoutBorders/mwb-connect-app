import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class LessonRequestModel {
  String? id;
  User? student;
  User? mentor;
  Subfield? subfield;
  DateTime? lessonDateTime;
  DateTime? sentDateTime;
  bool? isCanceled;
  bool? isRejected;
  bool? isExpired;
  bool? wasCanceledShown;
  bool? wasExpiredShown;

  LessonRequestModel({this.id, this.student, this.mentor, this.subfield, this.lessonDateTime, this.sentDateTime, this.isCanceled, this.isRejected, this.isExpired, this.wasCanceledShown, this.wasExpiredShown});

  LessonRequestModel.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    id = json['id'];
    student = _userFromJson(json['student']);
    mentor = _userFromJson(json['mentor']);
    subfield = _subfieldFromJson(json['subfield']);
    lessonDateTime = json['lessonDateTime'] != null ? dateFormat.parseUTC(json['lessonDateTime']).toLocal() : null;
    sentDateTime = json['sentDateTime'] != null ? dateFormat.parseUTC(json['sentDateTime']).toLocal() : null;
    isCanceled = json['isCanceled'];
    isRejected = json['isRejected'];
    isExpired = json['isExpired'];
    wasCanceledShown = json['wasCanceledShown'];
    wasExpiredShown = json['wasExpiredShown'];
  }

  User? _userFromJson(Map<String, dynamic>? json) {
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
      'student': student != null ? student?.toJson() : null,
      'mentor': mentor != null ? mentor?.toJson() : null,
      'subfield': subfield != null ? subfield?.toJson() : null,
      'lessonDateTime': lessonDateTime != null ? dateFormat.format(lessonDateTime!.toUtc()) : null,
      'sentDateTime': sentDateTime != null ? dateFormat.format(sentDateTime!.toUtc()) : null,
      'isCanceled': isCanceled,
      'isRejected': isRejected,
      'isExpired': isExpired,
      'wasCanceledShown': wasCanceledShown,
      'wasExpiredShown': wasExpiredShown
    };
  }
}