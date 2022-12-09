import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/student_course_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class StudentCourseViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final StudentCourseService _studentCourseService = locator<StudentCourseService>();
  final LoggerService _loggerService = locator<LoggerService>();  
  List<CourseType> coursesTypes = [];
  CourseType? courseType;
  CourseModel? course;
  List<CourseModel> availableCourses = [];
  CourseStudent? partnerStudent;
  bool _shouldUnfocus = false;
  bool shouldShowCanceled = false;

  Future<void> getCurrentCourse() async {
    course = await _studentCourseService.getCurrentCourse();
    notifyListeners();
  }

  Future<void> getAvailableCourses() async {
    availableCourses = await _studentCourseService.getAvailableCourses();
    notifyListeners();
  }
  
  Future<void> joinCourse() async {
    await _studentCourseService.joinCourse(course?.id);
  }  
  
  Future<void> cancelCourse(String? reason) async {
    await _studentCourseService.cancelCourse(course?.id, reason);
  }

  bool get isCourse => course != null && course?.id != null && course?.isCanceled != true;  

  DateTime getCourseEndDate() {
    return Jiffy(course?.startDateTime).add(months: 3).dateTime;
  }
  
  DateTime getNextLessonDate() {
    DateTime now = DateTime.now();
    Jiffy nextLessonDate = Jiffy(course?.startDateTime);
    while (nextLessonDate.isBefore(now)) {
      nextLessonDate.add(weeks: 1);
    }
    return nextLessonDate.dateTime;
  }    

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

  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }

  void addLogEntry(String text) {
    _loggerService.addLogEntry(text);
  }  
}
