import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';

class MentorWaitingRequest {
  String? id;
  CourseType? courseType;
  CourseMentor? mentor;

  MentorWaitingRequest({this.id, this.courseType, this.mentor});

  MentorWaitingRequest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    courseType = _courseTypeFromJson(json['courseType']);
    mentor = _mentorFromJson(json['mentor']);
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
    };
  }
}