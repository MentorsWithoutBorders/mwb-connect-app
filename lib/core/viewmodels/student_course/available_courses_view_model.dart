import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/field_goal_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/services/student_course/available_courses_api_service.dart';
import 'package:mwb_connect_app/core/services/student_course/available_courses_utils_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_utils_service.dart';
import 'package:mwb_connect_app/core/services/student_course/available_courses_texts_service.dart';
import 'package:mwb_connect_app/core/services/fields_goals_service.dart';

class AvailableCoursesViewModel extends ChangeNotifier {
  final AvailableCoursesApiService _availableCoursesApiService = locator<AvailableCoursesApiService>();
  final AvailableCoursesUtilsService _availableCoursesUtilsService = locator<AvailableCoursesUtilsService>();
  final StudentCourseUtilsService _studentCourseUtilsService = locator<StudentCourseUtilsService>();
  final AvailableCoursesTextsService _availableCoursesTextsService = locator<AvailableCoursesTextsService>();
  final FieldsGoalsService _fieldsGoalsService = locator<FieldsGoalsService>();  
  List<Field> fields = [];
  List<FieldGoal> fieldsGoals = [];
  List<CourseModel> availableCourses = [];
  List<CourseModel> newAvailableCourses = [];
  List<Availability> filterAvailabilities = [];
  Map<String, String> fieldIconFilePaths = {};
  Field filterField = Field();
  String availabilityMergedMessage = '';
  double scrollOffset = 0;
  bool _shouldUnfocus = false;

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
    newAvailableCourses = await _availableCoursesApiService.getAvailableCourses(filterField.id);
    availableCourses += newAvailableCourses;
  }

  Future<CourseModel> joinCourse(String? id) async {
    CourseModel? course = await _availableCoursesApiService.joinCourse(id);
    return course;
  }

  String getFieldName(CourseModel course) {
    return _availableCoursesUtilsService.getFieldName(course);
  }

  String getMentorsNames(CourseModel course) { 
    return _studentCourseUtilsService.getMentorsNames(course);
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
 
  void setFilterField(Field? field) {
    if (filterField.id != field?.id) {
      filterField = Field(
        id: field?.id, 
        name: field?.name, 
        subfields: []
      );
    }
    notifyListeners();
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
    filterAvailabilities = [];
    filterField = Field();
  }  
}