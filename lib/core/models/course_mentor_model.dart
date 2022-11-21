import 'package:mwb_connect_app/core/models/user_model.dart';

class CourseMentor extends User {
  String? meetingUrl;
  bool? isCanceled;

  CourseMentor({this.meetingUrl, this.isCanceled});

  CourseMentor.fromJson(Map<String, dynamic> json) {
    meetingUrl = json['meetingUrl'] ?? '';
    isCanceled = json['isCanceled'];
  }

  Map<String, Object?> toJson() {
    return {
      'meetingUrl': meetingUrl,
      'isCanceled': isCanceled
    };
  }
}