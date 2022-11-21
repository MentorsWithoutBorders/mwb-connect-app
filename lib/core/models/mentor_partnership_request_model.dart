import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';

class MentorPartnershipRequest {
  String? id;
  CourseType? courseType;
  CourseMentor? mentor;
  CourseMentor? partnerMentor;
  String? courseDayOfWeek;
  String? courseStartTime;
  bool? isRejected;
  bool? isCanceled;
  bool? isExpired;
  bool? wasCanceledShown;
  bool? wasExpiredShown;

  MentorPartnershipRequest({this.id, this.courseType, this.mentor, this.partnerMentor, this.courseDayOfWeek, this.courseStartTime, this.isRejected, this.isCanceled, this.isExpired, this.wasCanceledShown, this.wasExpiredShown});

  MentorPartnershipRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    courseType = _courseTypeFromJson(json['courseType']);
    mentor = _mentorFromJson(json['mentor']);
    partnerMentor = _mentorFromJson(json['partnerMentor']);
    courseDayOfWeek = json['courseDayOfWeek'];
    courseStartTime = json['courseStartTime'];
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
    return {
      'id': id,
      'courseType': courseType?.toJson(),
      'mentor': mentor?.toJson(),
      'partnerMentor': partnerMentor?.toJson(),
      'courseDayOfWeek': courseDayOfWeek,
      'courseStartTime': courseStartTime,
      'isRejected': isRejected,
      'isCanceled': isCanceled,
      'isExpired': isExpired,
      'wasCanceledShown': wasCanceledShown,
      'wasExpiredShown': wasExpiredShown
    };
  }
}