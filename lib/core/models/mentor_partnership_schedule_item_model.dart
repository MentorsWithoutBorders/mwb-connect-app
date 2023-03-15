import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';

class MentorPartnershipScheduleItemModel {
  String? id;
  CourseModel? course;
  CourseMentor? mentor;
  DateTime? lessonDateTime;

  MentorPartnershipScheduleItemModel({this.id, this.course, this.mentor, this.lessonDateTime});

  MentorPartnershipScheduleItemModel.fromJson(Map<String, dynamic> json) {
    DateFormat dateTimeFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    id = json['id'] ?? '';
    course = json['course'] != null ? CourseModel.fromJson(json['course']) : null;
    mentor = json['mentor'] != null ? CourseMentor.fromJson(json['mentor']) : null;
    lessonDateTime = json['lessonDateTime'] != null ? dateTimeFormat.parseUTC(json['lessonDateTime']).toLocal() : null;
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'course': course?.toJson(),
      'mentor': mentor?.toJson(),
      'lessonDateTime': lessonDateTime
    };
  }  
}