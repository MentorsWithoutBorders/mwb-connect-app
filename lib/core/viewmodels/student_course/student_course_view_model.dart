import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_api_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_texts_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_utils_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class StudentCourseViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final StudentCourseApiService _studentCourseApiService = locator<StudentCourseApiService>();
  final StudentCourseTextsService _studentCourseTextsService = locator<StudentCourseTextsService>();
  final StudentCourseUtilsService _studentCourseUtilsService = locator<StudentCourseUtilsService>();
  final LoggerService _loggerService = locator<LoggerService>();  
  CourseModel? course;
  CourseType? courseType;

  Future<void> getCourse() async {
    course = await _studentCourseApiService.getCourse();
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

  DateTime? getCertificateDate() {
    DateTime date = DateTime.now();
    if (_storageService.registeredOn != null) {
      DateTime registeredOn = DateTime.parse(_storageService.registeredOn as String);
      date = Jiffy(registeredOn).add(months: 3).dateTime;
    }
    return date;
  }

  bool shouldShowTrainingCompleted() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    return Utils.getDSTAdjustedDifferenceInDays(now, registeredOn) <= 7 * (AppConstants.studentWeeksTraining + 7);
  }  

  bool getShouldShowProductivityReminder() {
    DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');    
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = DateTime.parse(_storageService.registeredOn as String);
    return Utils.getDSTAdjustedDifferenceInDays(now, registeredOn) > 14 && _storageService.lastProductivityReminderShownDate != dateFormat.format(now);
  }

  void setLastShownProductivityReminderDate() {
    DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');
    String today = dateFormat.format(DateTime.now());
    _storageService.lastProductivityReminderShownDate = today;
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

  String getFieldName() {
    String fieldName = '';
    if (course?.mentors != null && course?.mentors?.length != 0) {
      fieldName = course?.mentors![0].field?.name as String;
    }
    return fieldName;
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

  void addLogEntry(String text) {
    _loggerService.addLogEntry(text);
  }  
}
