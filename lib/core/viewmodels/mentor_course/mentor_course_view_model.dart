import 'package:flutter/material.dart';
import 'package:mwb_connect_app/core/models/next_lesson_mentor_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_schedule_item_model.dart';
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
  List<CourseType> courseTypes = [];
  List<MentorPartnershipScheduleItemModel> mentorPartnershipSchedule = [];
  List<MentorWaitingRequest> mentorsWaitingRequests = [];
  MentorWaitingRequest? mentorWaitingRequest;
  MentorPartnershipRequestModel? mentorPartnershipRequest;
  CourseModel? course;
  NextLessonMentor? nextLesson;
  Field? field;
  CourseMentor? partnerMentor;
  CourseType? selectedCourseType;
  String? previousMeetingUrl = '';
  String errorMessage = '';
  bool _shouldUnfocus = false;
  bool shouldShowExpired = false;
  bool shouldShowCanceled = false;

  Future<void> getCourseTypes() async {
    courseTypes = await _mentorCourseApiService.getCourseTypes();
    if (selectedCourseType == null) {
      setSelectedCourseType(courseTypes[0].id as String);
    }
    notifyListeners();
  }

  Future<void> getCourse() async {
    course = await _mentorCourseApiService.getCourse();
    if (course?.id != null) {
      setSelectedCourseType(courseTypes[0].id as String);
    }
    notifyListeners();
  }

  Future<void> getPreviousCourse() async {
    CourseModel previousCourse = await _mentorCourseApiService.getPreviousCourse();
    CourseMentor mentor = _mentorCourseUtilsService.getMentor(previousCourse);
    if (mentor.meetingUrl != null && mentor.meetingUrl!.isNotEmpty) {
      previousMeetingUrl = mentor.meetingUrl as String;
    }
    notifyListeners();
  }

  Future<void> getNextLesson() async {
    nextLesson = await _mentorCourseApiService.getNextLesson();
    if (nextLesson?.lessonDateTime != null) {
      setSelectedCourseType(courseTypes[0].id as String);
    }
    notifyListeners();
  }

  Future<void> getMentorPartnershipSchedule() async {
    if (course?.id != null) {
      mentorPartnershipSchedule = await _mentorCourseApiService.getMentorPartnershipSchedule(course?.id);
      notifyListeners();
    }
  }

  Future<void> addCourse(Availability? availability, String meetingUrl) async {
    course = await _mentorCourseApiService.addCourse(course, selectedCourseType, availability, meetingUrl);
    notifyListeners();
  }

  Future<void> updateMentorPartnershipScheduleItem(String? id, String? mentorId) async {
    await _mentorCourseApiService.updateMentorPartnershipScheduleItem(id, mentorId);
    mentorPartnershipSchedule = _mentorCourseUtilsService.getUpdatedMentorPartnershipSchedule(mentorPartnershipSchedule, id, mentorId);
    notifyListeners();
  }

  Future<void> setMeetingUrl(String meetingUrl) async {
    await _mentorCourseApiService.setMeetingUrl(course?.id, meetingUrl);
    course = _mentorCourseUtilsService.getUpdatedMeetingUrl(course, meetingUrl);
    notifyListeners();
  }

  Future<void> setWhatsAppGroupUrl(String? whatsAppGroupUrl) async {
    await _mentorCourseApiService.setWhatsAppGroupUrl(course?.id, whatsAppGroupUrl);
    course?.whatsAppGroupUrl = whatsAppGroupUrl;
    notifyListeners();
  }

  Future<void> updateCourseNotes(String? courseNotes) async {
    await _mentorCourseApiService.updateCourseNotes(course?.id, courseNotes);
    course?.notes = courseNotes;
    notifyListeners();
  }

  Future<void> cancelCourse(String? reason) async {
    await _mentorCourseApiService.cancelCourse(course?.id, reason);
    course = null;
    setSelectedCourseType(courseTypes[0].id as String);
    notifyListeners();
  }

  Future<void> cancelNextLesson(String? reason) async {
    nextLesson = await _mentorCourseApiService.cancelNextLesson(course?.id, reason);
    setSelectedCourseType(courseTypes[0].id as String);
    notifyListeners();
  }

  Future<void> getField(String fieldId) async {
    field = await _mentorCourseApiService.getField(fieldId);
    notifyListeners();
  }

  Future<void> getMentorsWaitingRequests() async {
    mentorsWaitingRequests = await _mentorCourseApiService.getMentorsWaitingRequests();
    notifyListeners();
  }

  Future<void> getMentorWaitingRequest() async {
    mentorWaitingRequest = await _mentorCourseApiService.getMentorWaitingRequest();
    if (mentorWaitingRequest?.id != null) {
      setSelectedCourseType(courseTypes[0].id as String);
    }
    notifyListeners();
  }

  Future<void> addMentorWaitingRequest(MentorWaitingRequest mentorWaitingRequest) async {
    await _mentorCourseApiService.addMentorWaitingRequest(mentorWaitingRequest, selectedCourseType);
  }

  Future<void> cancelMentorWaitingRequest() async {
    await _mentorCourseApiService.cancelMentorWaitingRequest();
    mentorWaitingRequest = null;
    setSelectedCourseType(courseTypes[0].id as String);
    notifyListeners();
  }

  Future<void> getMentorPartnershipRequest() async {
    mentorPartnershipRequest = await _mentorCourseApiService.getMentorPartnershipRequest();
    shouldShowExpired = _mentorCourseUtilsService.getShouldShowMentorPartnershipRequestExpired(mentorPartnershipRequest);
    shouldShowCanceled = _mentorCourseUtilsService.getShouldShowMentorPartnershipRequestCanceled(mentorPartnershipRequest);
    if (shouldShowExpired) {
      await _mentorCourseApiService.updateMentorPartnershipRequest(mentorPartnershipRequest?.id, MentorPartnershipRequestModel(wasExpiredShown: true));
      mentorPartnershipRequest = null;
    }
    if (shouldShowCanceled) {
      await _mentorCourseApiService.updateMentorPartnershipRequest(mentorPartnershipRequest?.id, MentorPartnershipRequestModel(wasCanceledShown: true));
      mentorPartnershipRequest = null;
    }
    if (mentorPartnershipRequest?.id != null) {
      setSelectedCourseType(courseTypes[0].id as String);
    }    
    notifyListeners();
  }

  Future<void> acceptMentorPartnershipRequest(String? meetingUrl) async {
    course = await _mentorCourseApiService.acceptMentorPartnershipRequest(mentorPartnershipRequest?.id, meetingUrl as String);
    mentorPartnershipRequest = null;
    setSelectedCourseType(courseTypes[0].id as String);
    notifyListeners();
  }

  Future<void> rejectMentorPartnershipRequest(String? reason) async {
    await _mentorCourseApiService.rejectMentorPartnershipRequest(mentorPartnershipRequest?.id, reason);
    mentorPartnershipRequest = null;
    setSelectedCourseType(courseTypes[0].id as String);
    notifyListeners();
  }

  Future<void> cancelMentorPartnershipRequest() async {
    await _mentorCourseApiService.cancelMentorPartnershipRequest(mentorPartnershipRequest?.id);
    mentorPartnershipRequest = null;
    setSelectedCourseType(courseTypes[0].id as String);
    notifyListeners();
  }

  bool get isCourse => course != null && course?.id != null && course?.isCanceled != true;

  bool get isNextLesson => nextLesson != null && nextLesson?.lessonDateTime != null;

  bool get isCourseStarted => isCourse && course?.hasStarted == true;

  bool get isMentorPartnershipRequest =>
      (!isCourse || isCourse && !isNextLesson) &&
      mentorPartnershipRequest != null &&
      mentorPartnershipRequest?.id != null &&
      mentorPartnershipRequest?.isRejected != true &&
      mentorPartnershipRequest?.isCanceled != true &&
      mentorPartnershipRequest?.isExpired != true;

  bool get isMentorWaitingRequest => 
      (!isCourse || isCourse && !isNextLesson) && 
      !isMentorPartnershipRequest && 
      mentorWaitingRequest != null && 
      mentorWaitingRequest?.id != null;

  bool getIsMentorPartnershipRequestWaitingApproval(CourseMentor mentor) {
    return isMentorPartnershipRequest && mentorPartnershipRequest?.mentor?.id == mentor.id;
  }

  CourseMentor getPartnerMentor() {
    return _mentorCourseUtilsService.getPartnerMentor(course);
  }

  String getRequestPartnerMentorName() {
    return _mentorCourseUtilsService.getRequestPartnerMentorName(mentorPartnershipRequest);
  }

  void setMentorPartnershipRequest(MentorPartnershipRequestModel? mentorPartnershipRequest) {
    this.mentorPartnershipRequest = mentorPartnershipRequest;
    notifyListeners();
  }

  void setMentorWaitingRequest(MentorWaitingRequest? mentorWaitingRequest) {
    this.mentorWaitingRequest = mentorWaitingRequest;
    notifyListeners();
  }

  void setSelectedCourseType(String courseTypeId) {
    selectedCourseType = courseTypes.firstWhere((courseType) => courseType.id == courseTypeId);
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
    return _mentorCourseTextsService.getCourseText(course, nextLesson);
  }

  List<ColoredText> getMentorPartnershipScheduleText() {
    return _mentorCourseTextsService.getMentorPartnershipScheduleText(course);
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

  List<ColoredText> getMaximumStudentsText() {
    return _mentorCourseTextsService.getMaximumStudentsText(course);
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

  List<ColoredText> getWaitingMentorPartnershipApprovalText() {
    return _mentorCourseTextsService.getWaitingMentorPartnershipApprovalText(mentorPartnershipRequest);
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
