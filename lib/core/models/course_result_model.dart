import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/next_lesson_student_model.dart';

class CourseResult {
  CourseModel? course;
  NextLessonStudent? nextLesson;

  CourseResult({this.course, this.nextLesson});
}