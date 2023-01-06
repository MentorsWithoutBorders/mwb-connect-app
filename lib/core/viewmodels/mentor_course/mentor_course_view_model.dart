import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_api_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_texts_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_utils_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class MentorCourseViewModel extends ChangeNotifier {
  final MentorCourseApiService _mentorCourseApiService = locator<MentorCourseApiService>();
  final MentorCourseTextsService _mentorCourseTextsService = locator<MentorCourseTextsService>();
  final MentorCourseUtilsService _mentorCourseUtilsService = locator<MentorCourseUtilsService>();
  final LoggerService _loggerService = locator<LoggerService>();   
  List<CourseType> coursesTypes = [];
  MentorWaitingRequest? mentorWaitingRequest;
  List<MentorWaitingRequest> mentorsWaitingRequests = [];
  MentorPartnershipRequestModel? mentorPartnershipRequest;
  CourseModel? course;
  CourseMentor? partnerMentor;
  CourseType? selectedCourseType;
  String errorMessage = '';
  bool _shouldUnfocus = false;
  bool shouldShowExpired = false;
  bool shouldShowCanceled = false;

  Future<void> getCoursesTypes() async {
    coursesTypes = await _mentorCourseApiService.getCoursesTypes();
    selectedCourseType = coursesTypes[0];
    notifyListeners();
  }
  
  Future<void> getCourse() async {
    course = await _mentorCourseApiService.getCourse();
    notifyListeners();
  }
  
  Future<void> addCourse(Availability? availability, String meetingUrl) async {
    course = await _mentorCourseApiService.addCourse(course, selectedCourseType, availability, meetingUrl);
    notifyListeners();
  }

  Future<void> updateMeetingUrl(String meetingUrl) async {
    await _mentorCourseApiService.updateMeetingUrl(course?.id, meetingUrl);
    course = _mentorCourseUtilsService.getUpdatedMeetingUrl(course, meetingUrl);
    notifyListeners();
  }
  
  Future<void> cancelCourse(String? reason) async {
    await _mentorCourseApiService.cancelCourse(course?.id, reason);
    course = null;
    notifyListeners();
  }  

  Future<void> getMentorsWaitingRequests() async {
    mentorsWaitingRequests = await _mentorCourseApiService.getMentorsWaitingRequests();
    notifyListeners();
  }
  
  Future<void> getMentorWaitingRequest() async {
    mentorWaitingRequest = await _mentorCourseApiService.getMentorWaitingRequest();
    notifyListeners();
  }

  Future<void> addMentorWaitingRequest(MentorWaitingRequest mentorWaitingRequest) async {
    await _mentorCourseApiService.addMentorWaitingRequest(mentorWaitingRequest, selectedCourseType);
  }
  
  Future<void> cancelMentorWaitingRequest() async {
    await _mentorCourseApiService.cancelMentorWaitingRequest(mentorWaitingRequest?.id);
    notifyListeners();
  }

  Future<void> getMentorPartnershipRequest() async {
    mentorPartnershipRequest = await _mentorCourseApiService.getMentorPartnershipRequest();
    if (mentorPartnershipRequest != null && mentorPartnershipRequest?.id != null) {
      if (mentorPartnershipRequest?.isExpired != null && mentorPartnershipRequest?.isExpired == true) {
        if (mentorPartnershipRequest?.wasExpiredShown == null || mentorPartnershipRequest?.wasExpiredShown != null && mentorPartnershipRequest?.wasExpiredShown == false) {
          shouldShowExpired = true;
          await _mentorCourseApiService.updateMentorPartnershipRequest(mentorPartnershipRequest?.id, MentorPartnershipRequestModel(wasExpiredShown: true));
        }
        mentorPartnershipRequest = null;
      } else if (mentorPartnershipRequest?.isCanceled != null && mentorPartnershipRequest?.isCanceled == true) {
        if (mentorPartnershipRequest?.wasCanceledShown == null || mentorPartnershipRequest?.wasCanceledShown != null && mentorPartnershipRequest?.wasCanceledShown == false) {
          shouldShowCanceled = true;
          await _mentorCourseApiService.updateMentorPartnershipRequest(mentorPartnershipRequest?.id, MentorPartnershipRequestModel(wasCanceledShown: true));
        }
        mentorPartnershipRequest = null;
      }
    }
  }

  Future<void> acceptMentorPartnershipRequest(String? meetingUrl) async {
    await _mentorCourseApiService.acceptMentorPartnershipRequest(mentorPartnershipRequest?.id, meetingUrl as String);
    notifyListeners();
  }

  Future<void> rejectMentorPartnershipRequest(String? reason) async {
    await _mentorCourseApiService.rejectMentorPartnershipRequest(mentorPartnershipRequest?.id, reason);
    mentorPartnershipRequest?.isRejected = true;
    notifyListeners();
  }

  Future<void> cancelMentorPartnershipRequest() async {
    await _mentorCourseApiService.cancelMentorPartnershipRequest(mentorPartnershipRequest?.id);
    mentorPartnershipRequest?.isCanceled = true;
    notifyListeners();
  }

  bool get isCourse => course != null && course?.id != null && course?.isCanceled != true;
  
  bool get isMentorPartnershipRequest => !isCourse && mentorPartnershipRequest != null && mentorPartnershipRequest?.id != null && mentorPartnershipRequest?.isRejected != true;

  bool get isMentorWaitingRequest => !isCourse && mentorWaitingRequest != null && mentorWaitingRequest?.id != null;

  CourseMentor getPartnerMentor() {
    return _mentorCourseUtilsService.getPartnerMentor(course);
  }  

  void setSelectedCourseType(String courseTypeId) {
    selectedCourseType = coursesTypes.firstWhere((courseType) => courseType.id == courseTypeId);
    notifyListeners();
  }
  
  void setErrorMessage(String message) {
    errorMessage = message;
  } 

  bool shouldShowTrainingCompleted() {
    return _mentorCourseUtilsService.shouldShowTrainingCompleted();
  }

  String getMeetingUrl() {
    return _mentorCourseUtilsService.getMeetingUrl(course);
  }
  
  int getMentorsCount() {
    return _mentorCourseUtilsService.getMentorsCount(course);
  }
  
  int getStudentsCount() {
    return _mentorCourseUtilsService.getStudentsCount(course);
  }  

  List<ColoredText> getCourseText() {
    return _mentorCourseTextsService.getCourseText(course);
  }

  String getCancelCourseText() {
    return _mentorCourseTextsService.getCancelCourseText(course);
  }

  List<ColoredText> getWaitingStudentsNoPartnerText() {
    return _mentorCourseTextsService.getWaitingStudentsNoPartnerText(course);
  }

  List<ColoredText> getWaitingStudentsPartnerText() {
    return _mentorCourseTextsService.getWaitingStudentsPartnerText(course);
  }
  
  List<ColoredText> getCurrentStudentsText() {
    return _mentorCourseTextsService.getCurrentStudentsText(course);
  }

  List<ColoredText> getMentorPartnershipText() {
    return _mentorCourseTextsService.getMentorPartnershipText(mentorPartnershipRequest);
  }
  
  List<ColoredText> getMentorPartnershipBottomText() {
    return _mentorCourseTextsService.getMentorPartnershipBottomText(mentorPartnershipRequest);
  }

  List<ColoredText> getRejectMentorPartnershipText() {
    return _mentorCourseTextsService.getRejectMentorPartnershipText(mentorPartnershipRequest);
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
