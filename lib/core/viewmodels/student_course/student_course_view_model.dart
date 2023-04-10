import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/next_lesson_student_model.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/student_certificate.model.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_api_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_texts_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_utils_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class StudentCourseViewModel extends ChangeNotifier {
  final StudentCourseApiService _studentCourseApiService = locator<StudentCourseApiService>();
  final StudentCourseTextsService _studentCourseTextsService = locator<StudentCourseTextsService>();
  final StudentCourseUtilsService _studentCourseUtilsService = locator<StudentCourseUtilsService>();
  final LoggerService _loggerService = locator<LoggerService>();
  CourseModel? course;
  NextLessonStudent? nextLesson;
  CourseType? courseType;
  String? courseNotes;
  StudentCertificate? studentCertificate;

  Future<void> getCourse() async {
    course = await _studentCourseApiService.getCourse();
    notifyListeners();
  }

  Future<void> getNextLesson() async {
    nextLesson = await _studentCourseApiService.getNextLesson();
    notifyListeners();
  }

  Future<void> getCourseNotes() async {
    courseNotes = await _studentCourseApiService.getCourseNotes(course?.id);
    notifyListeners();
  }

  void setCourse(CourseModel course) {
    this.course = course;
    notifyListeners();
  }

  Future<void> cancelCourse(String? reason) async {
    await _studentCourseApiService.cancelCourse(course?.id, reason);
    course = null;
    notifyListeners();
  }

  Future<void> cancelNextLesson(String? reason) async {
    nextLesson = await _studentCourseApiService.cancelNextLesson(course?.id, reason);
    notifyListeners();
  }

  bool get isCourse => course != null && course?.id != null && course?.isCanceled != true;

  bool get isNextLesson => nextLesson != null && nextLesson?.lessonDateTime != null;

  bool get isCourseStarted => isCourse && course?.hasStarted == true;

  DateTime? getCertificateDate() {
    return _studentCourseUtilsService.getCertificateDate();
  }

  bool shouldShowTrainingCompleted() {
    return _studentCourseUtilsService.shouldShowTrainingCompleted();
  }

  bool getShouldShowProductivityReminder() {
    return _studentCourseUtilsService.getShouldShowProductivityReminder();
  }

  void setLastShownProductivityReminderDate() {
    _studentCourseUtilsService.setLastShownProductivityReminderDate();
  }

  Future<void> getCertificateSent() async {
    studentCertificate = await _studentCourseApiService.getCertificateSent();
  }

  List<String> getMentorsNames() {
    return _studentCourseUtilsService.getMentorsNames(course?.mentors) as List<String>;
  }

  CourseMentor getMentor() {
    return _studentCourseUtilsService.getMentor(course);
  }

  CourseMentor getPartnerMentor() {
    return _studentCourseUtilsService.getPartnerMentor(course);
  }

  List<ColoredText> getCourseText() {
    return _studentCourseTextsService.getCourseText(course, nextLesson);
  }

  List<ColoredText> getWaitingStartCourseText() {
    return _studentCourseTextsService.getWaitingStartCourseText(course);
  }

  List<ColoredText> getCurrentStudentsText() {
    return _studentCourseTextsService.getCurrentStudentsText(course);
  }

  List<String> getLogsList(String? selectedGoalId, String? lastStepAddedId, List<Quiz>? quizzes) {
    return _studentCourseUtilsService.getLogsList(selectedGoalId, lastStepAddedId, quizzes, course);
  }

  void sendAPIDataLogs(int i, String error, List<String> logs) {
    _studentCourseUtilsService.sendAPIDataLogs(i, error, logs);
  }

  void addLogEntry(String text) {
    _loggerService.addLogEntry(text);
  }  
}
