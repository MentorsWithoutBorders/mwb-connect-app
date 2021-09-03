import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class LessonNote {
  String? lessonId;
  String? text;
  DateTime? dateTime;

  LessonNote({this.lessonId, this.text, this.dateTime});

  LessonNote.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    lessonId = json['lessonId'];
    text = json['text'];
    dateTime = json['dateTime'] != null ? dateFormat.parseUTC(json['dateTime']).toLocal() : null;
  }

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    return {
      'lessonId': lessonId,
      'text': text,
      'dateTime': dateTime != null ? dateFormat.format(dateTime!.toUtc()) : null,
    };
  }
}