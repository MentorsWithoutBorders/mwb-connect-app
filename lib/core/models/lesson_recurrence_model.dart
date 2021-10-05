import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/lesson_recurrence_type.dart';

class LessonRecurrenceModel {
  bool isRecurrent = false;
  bool isRecurrenceDateSelected = false;
  DateTime? dateTime;
  DateTime? endRecurrenceDateTime;
  LessonRecurrenceType type = LessonRecurrenceType.lessons;
  int lessonsNumber = AppConstants.minLessonsNumberRecurrence;

  LessonRecurrenceModel({
    this.isRecurrent = false,
    this.isRecurrenceDateSelected = false,
    this.dateTime,
    this.endRecurrenceDateTime,
    this.type = LessonRecurrenceType.lessons,
    this.lessonsNumber = AppConstants.minLessonsNumberRecurrence
  });
}