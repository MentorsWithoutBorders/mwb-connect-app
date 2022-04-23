import 'package:mwb_connect_app/utils/constants.dart';

class LessonRecurrenceModel {
  bool isRecurrent = false;
  bool isRecurrenceDateSelected = false;
  DateTime? dateTime;
  DateTime? endRecurrenceDateTime;
  int lessonsNumber = AppConstants.minLessonsNumberRecurrence;

  LessonRecurrenceModel({
    this.isRecurrent = false,
    this.isRecurrenceDateSelected = false,
    this.dateTime,
    this.endRecurrenceDateTime,
    this.lessonsNumber = AppConstants.minLessonsNumberRecurrence
  });
}