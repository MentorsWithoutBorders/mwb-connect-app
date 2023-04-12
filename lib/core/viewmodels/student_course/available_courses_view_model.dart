import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/next_lesson_student_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/field_goal_model.dart';
import 'package:mwb_connect_app/core/models/error_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/course_filter_model.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_api_service.dart';
import 'package:mwb_connect_app/core/services/student_course/available_courses_api_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_api_service.dart';
import 'package:mwb_connect_app/core/services/student_course/available_courses_utils_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_utils_service.dart';
import 'package:mwb_connect_app/core/services/student_course/available_courses_texts_service.dart';
import 'package:mwb_connect_app/core/services/fields_goals_service.dart';

class AvailableCoursesViewModel extends ChangeNotifier {
  final AvailableCoursesApiService _availableCoursesApiService = locator<AvailableCoursesApiService>();
  final MentorCourseApiService _mentorCourseApiService = locator<MentorCourseApiService>();
  final StudentCourseApiService _studentCourseApiService = locator<StudentCourseApiService>();
  final AvailableCoursesUtilsService _availableCoursesUtilsService = locator<AvailableCoursesUtilsService>();
  final StudentCourseUtilsService _studentCourseUtilsService = locator<StudentCourseUtilsService>();
  final AvailableCoursesTextsService _availableCoursesTextsService = locator<AvailableCoursesTextsService>();
  final FieldsGoalsService _fieldsGoalsService = locator<FieldsGoalsService>();  
  List<CourseType> courseTypes = [];  
  List<Field> fields = [];
  List<FieldGoal> fieldsGoals = [];
  List<CourseModel> availableCourses = [];
  List<CourseModel> newAvailableCourses = [];
  List<Availability> filterAvailabilities = [];
  Map<String, String> fieldIconFilePaths = {};
  CourseType filterCourseType = CourseType();
  Field filterField = Field();
  String availabilityMergedMessage = '';
  double scrollOffset = 0;
  bool _shouldUnfocus = false;

  Future<void> getCourseTypes() async {
    courseTypes = await _mentorCourseApiService.getCourseTypes();
    courseTypes = _availableCoursesUtilsService.removeDuplicateDurations(courseTypes);
    CourseType allCourseType = CourseType(id: 'all');
    courseTypes.insert(0, allCourseType);
    filterCourseType = courseTypes[0];
    notifyListeners();
  }

  Future<void> getFields() async {
    fields = await _availableCoursesApiService.getFields();
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

  String? getWhyChooseUrl(String fieldId) {
    for (FieldGoal fieldGoal in fieldsGoals) {
      if (fieldGoal.fieldId == fieldId) {
        return fieldGoal.whyChooseUrl;
      }
    }
  }  

  Future<void> getAvailableCourses({int pageNumber = 1}) async {
    CourseFilter filter = CourseFilter(
      courseType: filterCourseType,
      field: filterField,
      availabilities: _adjustFilterAvailabilities(filterAvailabilities)
    );
    newAvailableCourses = await _availableCoursesApiService.getAvailableCourses(filter, pageNumber);
    availableCourses += newAvailableCourses;
  }

  Future<CourseModel> joinCourse(String? id) async {
    try {
      CourseModel? course = await _availableCoursesApiService.joinCourse(id);
      return course;
    } on ErrorModel catch(error) {
      throw(error);
    }    
  }

  Future<NextLessonStudent> getNextLesson() async {
    NextLessonStudent nextLesson = await _studentCourseApiService.getNextLesson();
    return nextLesson;
  }  

  String getFieldName(CourseModel course) {
    return _availableCoursesUtilsService.getFieldName(course);
  }

  String getCourseTypeText(CourseModel course) {
    return _availableCoursesTextsService.getCourseTypeText(course);
  }

  String getMentorsNames(CourseModel course) { 
    return _studentCourseUtilsService.getMentorsNames(course.mentors);
  }

  List<Subfield> getMentorsSubfields(CourseModel course) {
    return _availableCoursesUtilsService.getMentorsSubfields(course);
  }

  String getCourseScheduleText(CourseModel? course) {
    return _availableCoursesTextsService.getCourseScheduleText(course);
  }

  List<ColoredText> getJoinCourseText(CourseModel? course) {
    return _availableCoursesTextsService.getJoinCourseText(course);
  }

  List<Availability> _adjustFilterAvailabilities(List<Availability> filterAvailabilities) {
    return _availableCoursesUtilsService.adjustFilterAvailabilities(filterAvailabilities);
  } 

  List<Skill> setAllSkills(Field field) {
    return _availableCoursesUtilsService.setAllSkills(field);
  }  

  void addAvailability(Availability availability) {
    filterAvailabilities.add(availability);
    _sortFilterAvailabilities();
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(filterAvailabilities, availabilityMergedMessage);
    filterAvailabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    notifyListeners();
  }
  
  void _sortFilterAvailabilities() {
    filterAvailabilities = _availableCoursesUtilsService.sortFilterAvailabilities(filterAvailabilities);
    notifyListeners();
  }
  
  void updateAvailability(int index, Availability newAvailability) {
    filterAvailabilities[index] = newAvailability;
    _sortFilterAvailabilities();
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(filterAvailabilities, availabilityMergedMessage);
    filterAvailabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    notifyListeners();
  }
  
  void deleteAvailability(int index) {
    filterAvailabilities.removeAt(index);
    notifyListeners();
  }

  void setFilterCourseType(String? courseTypeId) {
    if (filterCourseType.id != courseTypeId) {
      filterCourseType = getCourseTypeById(courseTypeId);
    }
    notifyListeners();
  }
 
  void setFilterField(String? fieldId) {
    if (filterField.id != fieldId) {
      filterField = Field(
        id: fieldId, 
        name: getFieldById(fieldId).name,
        subfields: []
      );
    }
    notifyListeners();
  }

  Field getFieldById(String? fieldId) {
    Field? field = fields.firstWhere((Field field) => field.id == fieldId, orElse: () => Field());
    return field;
  }

  CourseType getCourseTypeById(String? courseTypeId) {
    CourseType? courseType = courseTypes.firstWhere((CourseType courseType) => courseType.id == courseTypeId, orElse: () => CourseType());
    return courseType;
  }

  Field getSelectedField() {
    return _availableCoursesUtilsService.getSelectedField(filterField, fields);
  }

  void setSubfield(Subfield subfield, int index) {
    filterField = _availableCoursesUtilsService.setSubfield(subfield, index, filterField);
    notifyListeners();
  }

  void addSubfield() {
    filterField = _availableCoursesUtilsService.addSubfield(filterField, fields);
    notifyListeners();
  }
  
  void deleteSubfield(int index) async {
    List<Subfield> updatedSubfields = _availableCoursesUtilsService.getSubfieldsAfterDelete(index, filterField);
    filterField.subfields = [];
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    filterField.subfields = updatedSubfields;
    notifyListeners();    
  }

  bool addSkill(String skill, int index) {
    Skill? skillToAdd = UtilsFields.setSkillToAdd(skill, index, filterField, fields);
    if (skillToAdd != null) {
      filterField.subfields?[index].skills?.add(skillToAdd);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void deleteSkill(String skillId, int index) {
    filterField = _availableCoursesUtilsService.deleteSkill(skillId, index, filterField);
    notifyListeners();
  }  

  void resetAvailabilityMergedMessage() {
    availabilityMergedMessage = '';
  }  
  
  void setScrollOffset(double positionDy, double screenHeight, double statusBarHeight) {
    scrollOffset = _availableCoursesUtilsService.setScrollOffset(positionDy, screenHeight, statusBarHeight);
  }
  
  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }

  void resetValues() {
    availableCourses = [];
    filterCourseType = CourseType(id: 'all');
    filterAvailabilities = [];
    filterField = Field();
  }  
}
