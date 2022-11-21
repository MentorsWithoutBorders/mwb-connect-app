import 'package:mwb_connect_app/core/models/user_model.dart';

class CourseStudent extends User {
  bool? isCanceled;

  CourseStudent({this.isCanceled});

  CourseStudent.fromJson(Map<String, dynamic> json) {
    isCanceled = json['isCanceled'];
  }

  Map<String, Object?> toJson() {
    return {
      'isCanceled': isCanceled
    };
  }
}