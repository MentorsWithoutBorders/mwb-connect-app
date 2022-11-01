import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class Goal {
  String? id;
  String? userId;
  String? text;
  int? position;
  DateTime? dateTime;

  Goal({this.id, this.userId, this.text, this.position, this.dateTime});

  Goal.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    id = json['id'];
    userId = json['userId'];
    text = json['text'] ?? '';
    position = json['position'] ?? 0;
    dateTime = json['dateTime'] != null ? dateFormat.parseUTC(json['dateTime']).toLocal() : null;
  }

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    return {
      'id': id,
      'userId': userId,
      'text': text,
      'position': position,
      'dateTime': dateTime != null ? dateFormat.format(dateTime!.toUtc()) : null
    };
  }
}