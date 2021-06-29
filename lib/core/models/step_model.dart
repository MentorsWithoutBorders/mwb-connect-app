import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class StepModel {
  String id;
  String parentId;
  String text;
  int level;
  int index;
  DateTime dateTime;

  StepModel({this.id, this.parentId, this.text, this.level, this.index, this.dateTime});

  StepModel.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    id = json['id'];
    parentId = json['parentId'];
    text = json['text'] ?? '';
    level = json['level'] ?? 0;
    index = json['index'] ?? 0;
    dateTime = json['dateTime'] != null ? dateFormat.parseUTC(json['dateTime']).toLocal() : null;
  }

  Map<String, Object> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    return {
      'parentId': parentId,
      'text': text,
      'level': level,
      'index': index,
      'dateTime': dateTime != null ? dateFormat.format(dateTime.toUtc()) : null,
    };
  }
}