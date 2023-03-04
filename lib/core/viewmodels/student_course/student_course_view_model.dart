import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/student_certificate.model.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_api_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_texts_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_utils_service.dart';

class StudentCourseViewModel extends ChangeNotifier {
  final StudentCourseApiService _studentCourseApiService = locator<StudentCourseApiService>();
  final StudentCourseTextsService _studentCourseTextsService = locator<StudentCourseTextsService>();
  final StudentCourseUtilsService _studentCourseUtilsService = locator<StudentCourseUtilsService>();  
  CourseModel? course;
  CourseType? courseType;
  String? courseNotes;
  StudentCertificate? studentCertificate;

  Future<void> getCourse() async {
    course = await _studentCourseApiService.getCourse();
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
  }

  bool get isCourse => course != null && course?.id != null && course?.isCanceled != true;
  
  bool get isCourseStarted => isCourse && course!.students != null && course!.students!.length >= AppConstants.minStudentsCourse;

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
    return _studentCourseUtilsService.getMentorsNames(course) as List<String>;
  }

  CourseMentor getMentor() {
    return _studentCourseUtilsService.getMentor(course);
  }

  CourseMentor getPartnerMentor() {
    return _studentCourseUtilsService.getPartnerMentor(course);
  }

  List<ColoredText> getCourseText() {
    return _studentCourseTextsService.getCourseText(course);
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
}
