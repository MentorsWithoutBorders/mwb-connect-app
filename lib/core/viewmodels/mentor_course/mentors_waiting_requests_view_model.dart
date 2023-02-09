import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentors_waiting_requests_api_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentors_waiting_requests_utils_service.dart';

class MentorsWaitingRequestsViewModel extends ChangeNotifier {
  final MentorsWaitingRequestsApiService _mentorsWaitingRequestsApiService = locator<MentorsWaitingRequestsApiService>();
  final MentorsWaitingRequestsUtilsService _mentorsWaitingRequestsUtilsService = locator<MentorsWaitingRequestsUtilsService>();
  List<MentorWaitingRequest> mentorsWaitingRequests = [];
  List<MentorWaitingRequest> newMentorsWaitingRequests = [];
  List<Field> fields = [];
  List<Availability> filterAvailabilities = [];
  Field filterField = Field();
  MentorPartnershipRequestModel? mentorPartnershipRequest;
  MentorWaitingRequest? mentorWaitingRequest;
  CourseType? selectedCourseType;
  CourseMentor? selectedPartnerMentor;
  String? availabilityOptionId;
  String? subfieldOptionId;
  String? mentorPartnershipRequestButtonId;
  String availabilityMergedMessage = '';
  double scrollOffset = 0;
  bool _shouldUnfocus = false;

  Future<void> getMentorsWaitingRequests({CourseType? courseType, int pageNumber = 1}) async {
    CourseMentor filterMentor = CourseMentor(
      field: filterField,
      availabilities: _adjustFilterAvailabilities(filterAvailabilities)
    );
    MentorWaitingRequest filter = MentorWaitingRequest(
      mentor: filterMentor,
      courseType: courseType
    );
    newMentorsWaitingRequests = await _mentorsWaitingRequestsApiService.getMentorsWaitingRequests(courseType, filter, pageNumber);
    newMentorsWaitingRequests = _adjustMentorsAvailabilities(newMentorsWaitingRequests);
    newMentorsWaitingRequests = _splitMentorsAvailabilities(newMentorsWaitingRequests);
    newMentorsWaitingRequests = _sortMentorsAvailabilities(newMentorsWaitingRequests);
    mentorsWaitingRequests += newMentorsWaitingRequests;
    setSelectedCourseType(courseType);
    setSelectedPartnerMentor(mentor: null);
  }

  Future<MentorWaitingRequest> addMentorWaitingRequest(CourseType courseType) async {
    mentorWaitingRequest = await _mentorsWaitingRequestsApiService.addMentorWaitingRequest(courseType);
    return mentorWaitingRequest!;
  }

  Future<void> sendMentorPartnershipRequest(CourseMentor mentor, String mentorSubfieldId, String courseStartTime) async {
    String courseDayOfWeek = selectedPartnerMentor?.availabilities![0].dayOfWeek as String;
    mentorPartnershipRequest = await _mentorsWaitingRequestsApiService.sendMentorPartnershipRequest(mentor, selectedPartnerMentor, selectedCourseType, courseDayOfWeek, courseStartTime);
    notifyListeners();
  }

  List<Availability> _adjustFilterAvailabilities(List<Availability> filterAvailabilities) {
    return _mentorsWaitingRequestsUtilsService.adjustFilterAvailabilities(filterAvailabilities);
  } 

  List<Skill> setAllSkills(Field field) {
    return _mentorsWaitingRequestsUtilsService.setAllSkills(field);
  }  

  List<MentorWaitingRequest> _adjustMentorsAvailabilities(List<MentorWaitingRequest> mentorsWaitingRequests) {
    return _mentorsWaitingRequestsUtilsService.adjustMentorsAvailabilities(mentorsWaitingRequests);
  }

  List<MentorWaitingRequest> _splitMentorsAvailabilities(List<MentorWaitingRequest> mentorsWaitingRequests) {
    return _mentorsWaitingRequestsUtilsService.splitMentorsAvailabilities(mentorsWaitingRequests);
  }

  List<MentorWaitingRequest> _sortMentorsAvailabilities(List<MentorWaitingRequest> mentorsWaitingRequests) {
    return _mentorsWaitingRequestsUtilsService.sortMentorsAvailabilities(mentorsWaitingRequests);
  }

  void setSelectedPartnerMentor({CourseMentor? mentor, Subfield? subfield, Availability? availability}) {
    if (mentor != null) {
      if (subfieldOptionId != null && !subfieldOptionId!.contains(mentor.id as String)) {
        subfieldOptionId = null;
      }
      if (availabilityOptionId != null && !availabilityOptionId!.contains(mentor.id as String)) {
        availabilityOptionId = null;
      }
      if (subfieldOptionId == null) {
        setDefaultSubfield(mentor);
      }
      if (availabilityOptionId == null) {
        setDefaultAvailability(mentor);
      }
      setMentorPartnershipRequestButtonId(mentor.id);
      if (selectedPartnerMentor == null) {
        selectedPartnerMentor = CourseMentor(id: mentor.id);
        selectedPartnerMentor?.field = Field(
          id: mentor.field?.id,
          subfields: subfield != null ? [subfield] : [getSelectedSubfield()]
        );
        selectedPartnerMentor?.availabilities = availability != null ? [availability] : [getSelectedAvailability()];
      }
    } else {
      selectedPartnerMentor = null;
    }
    notifyListeners();
  }

  void setSelectedCourseType(CourseType? courseType) {
    selectedCourseType = courseType;
    notifyListeners();
  }   

  void setAvailabilityOptionId(String? id) {
    availabilityOptionId = id;
    if (id != null) {
      String mentorId = id.substring(0, id.indexOf('-a-'));
      setSelectedPartnerMentor(mentor: null);
      setMentorPartnershipRequestButtonId(null);
      if (subfieldOptionId != null && !subfieldOptionId!.contains(mentorId)) {
        subfieldOptionId = null;
      }
    }
    notifyListeners();
  }

  void setSubfieldOptionId(String? id) {
    subfieldOptionId = id;
    if (id != null) {
      String mentorId = id.substring(0, id.indexOf('-s-'));
      setSelectedPartnerMentor(mentor: null);
      setMentorPartnershipRequestButtonId(null);
      if (availabilityOptionId != null && !availabilityOptionId!.contains(mentorId)) {
        availabilityOptionId = null;
      }
    }
    notifyListeners();
  }

  void setMentorPartnershipRequestButtonId(String? id) {
    mentorPartnershipRequestButtonId = id;   
    notifyListeners();
  }

  void setDefaultSubfield(CourseMentor mentor) {
    setSubfieldOptionId(_mentorsWaitingRequestsUtilsService.getDefaultSubfield(mentor, subfieldOptionId, mentorPartnershipRequestButtonId));
    notifyListeners();
  }

  void setDefaultAvailability(CourseMentor mentor) {
    setAvailabilityOptionId(_mentorsWaitingRequestsUtilsService.getDefaultAvailability(mentor, availabilityOptionId, mentorPartnershipRequestButtonId));
    notifyListeners();
  }
  
  String getErrorMessage(CourseMentor mentor) {
    return _mentorsWaitingRequestsUtilsService.getErrorMessage(mentor.id, mentorPartnershipRequestButtonId, subfieldOptionId, availabilityOptionId);
  }

  String getSubfieldItemId(String mentorId, int index) {
    return _mentorsWaitingRequestsUtilsService.getSubfieldItemId(mentorId, index);
  }
  
  String getAvailabilityItemId(String mentorId, int index) {
    return _mentorsWaitingRequestsUtilsService.getAvailabilityItemId(mentorId, index);
  }

  Subfield getSelectedSubfield() {
    return _mentorsWaitingRequestsUtilsService.getSelectedSubfield(subfieldOptionId, mentorsWaitingRequests, selectedPartnerMentor);
  }

  Availability getSelectedAvailability() {
    return _mentorsWaitingRequestsUtilsService.getSelectedAvailability(availabilityOptionId, mentorsWaitingRequests, selectedPartnerMentor);
  }

  List<String> buildHoursList() {
    return _mentorsWaitingRequestsUtilsService.buildHoursList(availabilityOptionId, mentorsWaitingRequests, selectedPartnerMentor);
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
    filterAvailabilities = _mentorsWaitingRequestsUtilsService.sortFilterAvailabilities(filterAvailabilities);
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
    return _mentorsWaitingRequestsUtilsService.getSelectedField(filterField, fields);
  }

  void setSubfield(Subfield subfield, int index) {
    filterField = _mentorsWaitingRequestsUtilsService.setSubfield(subfield, index, filterField);
    notifyListeners();
  }

  void addSubfield() {
    filterField = _mentorsWaitingRequestsUtilsService.addSubfield(filterField, fields);
    notifyListeners();
  }
  
  void deleteSubfield(int index) async {
    List<Subfield> updatedSubfields = _mentorsWaitingRequestsUtilsService.getSubfieldsAfterDelete(index, filterField);
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
    filterField = _mentorsWaitingRequestsUtilsService.deleteSkill(skillId, index, filterField);
    notifyListeners();
  }  

  void resetAvailabilityMergedMessage() {
    availabilityMergedMessage = '';
  }  
  
  void setScrollOffset(double positionDy, double screenHeight, double statusBarHeight) {
    scrollOffset = _mentorsWaitingRequestsUtilsService.setScrollOffset(positionDy, screenHeight, statusBarHeight);
  }
  
  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }

  void resetValues() {
    mentorsWaitingRequests = [];
    filterAvailabilities = [];
    filterField = Field();
    mentorPartnershipRequest = null;
    mentorWaitingRequest = null;
    selectedPartnerMentor = null;
    subfieldOptionId = null;
    availabilityOptionId = null;
    mentorPartnershipRequestButtonId = null;
  }  
}