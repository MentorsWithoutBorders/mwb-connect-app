import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class StepModel {
  String? id;
  String? userId;
  String? goalId;
  String? parentId;
  String? text;
  int? level;
  int? position;
  DateTime? dateTime;

  StepModel({this.id, this.userId, this.goalId, this.parentId, this.text, this.level, this.position, this.dateTime});

  StepModel.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    id = json['id'];
    userId = json['userId'];
    goalId = json['goalId'];
    parentId = json['parentId'];
    text = json['text'] ?? '';
    level = json['level'] ?? 0;
    position = json['position'] ?? 0;
    dateTime = json['dateTime'] != null ? dateFormat.parseUTC(json['dateTime']).toLocal() : null;
  }

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    return {
      'id': id,
      'userId': userId,
      'goalId': goalId,
      'parentId': parentId,
      'text': text,
      'level': level,
      'position': position,
      'dateTime': dateTime != null ? dateFormat.format(dateTime!.toUtc()) : null,
    };
  }
}