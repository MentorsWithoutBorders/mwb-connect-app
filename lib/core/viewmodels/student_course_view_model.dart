import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jiffy/jiffy.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/field_goal_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/student_course_service.dart';
import 'package:mwb_connect_app/core/services/fields_goals_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class StudentCourseViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final StudentCourseService _studentCourseService = locator<StudentCourseService>();
  final FieldsGoalsService _fieldsGoalsService = locator<FieldsGoalsService>();
  final LoggerService _loggerService = locator<LoggerService>();  
  List<Field> fields = [];
  List<CourseModel> availableCourses = [];
  List<CourseModel> newAvailableCourses = [];
  List<CourseType> coursesTypes = [];
  List<FieldGoal> fieldsGoals = [];
  CourseModel? course;
  CourseType? courseType;
  Map<String, String> fieldIconFilePaths = {};

  Future<void> getCurrentCourse() async {
    course = await _studentCourseService.getCurrentCourse();
    notifyListeners();
  }

  Future<void> getAvailableCourses({String? fieldId, int pageNumber = 1}) async {
    newAvailableCourses = await _studentCourseService.getAvailableCourses(fieldId);
    availableCourses += newAvailableCourses;
    notifyListeners();
  }
  
  Future<void> joinCourse(String courseId) async {
    await _studentCourseService.joinCourse(courseId);
  }  
  
  Future<void> cancelCourse(String? reason) async {
    await _studentCourseService.cancelCourse(course?.id, reason);
  }

  Future<void> getFields() async {
    fields = await _studentCourseService.getFields();
    await _getFieldIconFilePaths();
  }

  Future<void> getFieldsGoals() async {
    fieldsGoals = await _fieldsGoalsService.getFieldsGoals();
  }    

  Future<void> _getFieldIconFilePaths() async {
    for (Field field in fields) {
      String fieldName = field.name?.toLowerCase().replaceAll(' ', '-') as String;
      String filePath = '';
      try {
        final String fieldIconFile = 'assets/images/fields/' + fieldName + '.png';
        await rootBundle.load(fieldIconFile);
        filePath = fieldIconFile;
      } catch(_) {
        final Reference ref = FirebaseStorage.instance.ref().child('images').child(fieldName + '.png');
        filePath = await ref.getDownloadURL();
      }      
      fieldIconFilePaths.putIfAbsent(field.name as String, () => filePath);
    }
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

  List<String> getMentorsNames() {
    List<String> names = [];
    if (course?.mentors != null && course?.mentors?.length != 0) {
      names.add(course?.mentors![0].name as String);
      if (course!.mentors!.length > 1) {
        names.add(course?.mentors![1].name as String);
      }
    }
    return names;
  }

  String getFieldName() {
    String fieldName = '';
    if (course?.mentors != null && course?.mentors?.length != 0) {
      fieldName = course?.mentors![0].field?.name as String;
    }
    return fieldName;
  }

  List<Subfield> getMentorsSubfields() {
    List<Subfield> subfields = [];
    List<Subfield>? mentorSubfields = course?.mentors![0].field?.subfields;
    if (mentorSubfields != null && mentorSubfields.length > 0) {
      subfields.add(mentorSubfields[0]);
      CourseMentor? partnerMentor = course?.mentors![1];
      List<Subfield>? partnerMentorSubfields = partnerMentor?.field?.subfields;
      if (partnerMentorSubfields != null && partnerMentorSubfields.length > 0) {
        if (partnerMentorSubfields[0].id != mentorSubfields[0].id) {
          subfields.add(partnerMentorSubfields[0]);
        } else {
          subfields[0].skills?.addAll(partnerMentorSubfields[0].skills as List<Skill>);
          // Remove duplicate skills
          subfields[0].skills = subfields[0].skills?.toSet().toList();
        }
      }        
    }
    return subfields;
  }

  String? getWhyChooseUrl(String fieldId) {
    for (FieldGoal fieldGoal in fieldsGoals) {
      if (fieldGoal.fieldId == fieldId) {
        return fieldGoal.whyChooseUrl;
      }
    }
  }

  void addLogEntry(String text) {
    _loggerService.addLogEntry(text);
  }  
}
