import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class LessonRequestModel {
  String id;
  User student;
  User mentor;
  Subfield subfield;
  bool isCanceled;

  LessonRequestModel({this.id, this.student, this.mentor, this.subfield, this.isCanceled});

  LessonRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    student = _userFromJson(json['student']) ?? null;
    mentor = _userFromJson(json['mentor']) ?? null;
    subfield = _subfieldFromJson(json['subfield']) ?? null;
    isCanceled = json['isCanceled'] ?? null;
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
    return {
      'id': id,
      'student': student.toJson(),
      'mentor': mentor.toJson(),
      'subfield': subfield.toJson(),
      'isCanceled': isCanceled
    };
  }
}