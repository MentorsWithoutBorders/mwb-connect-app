import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';

class MentorPartnershipRequestModel {
  String? id;
  CourseType? courseType;
  CourseMentor? mentor;
  CourseMentor? partnerMentor;
  String? courseDayOfWeek;
  String? courseStartTime;
  DateTime? sentDateTime;  
  bool? isRejected;
  bool? isCanceled;
  bool? isExpired;
  bool? wasCanceledShown;
  bool? wasExpiredShown;

  MentorPartnershipRequestModel({this.id, this.courseType, this.mentor, this.partnerMentor, this.courseDayOfWeek, this.courseStartTime, this.sentDateTime, this.isRejected, this.isCanceled, this.isExpired, this.wasCanceledShown, this.wasExpiredShown});

  MentorPartnershipRequestModel.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    id = json['id'];
    courseType = _courseTypeFromJson(json['courseType']);
    mentor = _mentorFromJson(json['mentor']);
    partnerMentor = _mentorFromJson(json['partnerMentor']);
    courseDayOfWeek = json['courseDayOfWeek'];
    courseStartTime = json['courseStartTime'];
    sentDateTime = json['sentDateTime'] != null ? dateFormat.parseUTC(json['sentDateTime']).toLocal() : null;    
    isRejected = json['isRejected'];
    isCanceled = json['isCanceled'];
    isExpired = json['isExpired'];
    wasCanceledShown = json['wasCanceledShown'];
    wasExpiredShown = json['wasExpiredShown'];
  }

  CourseType? _courseTypeFromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return CourseType.fromJson(json);
    }
    return null;
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
      'id': id,
      'courseType': courseType?.toJson(),
      'mentor': mentor?.toJson(),
      'partnerMentor': partnerMentor?.toJson(),
      'courseDayOfWeek': courseDayOfWeek,
      'courseStartTime': courseStartTime,
      'sentDateTime': sentDateTime != null ? dateFormat.format(sentDateTime!.toUtc()) : null,
      'isRejected': isRejected,
      'isCanceled': isCanceled,
      'isExpired': isExpired,
      'wasCanceledShown': wasCanceledShown,
      'wasExpiredShown': wasExpiredShown
    };
  }
}