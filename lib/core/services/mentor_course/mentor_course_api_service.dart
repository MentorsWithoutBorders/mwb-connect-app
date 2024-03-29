import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/next_lesson_mentor_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_schedule_item_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/attached_message_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_utils_service.dart';

class MentorCourseApiService {
  final ApiService _api = locator<ApiService>();
  final MentorCourseUtilsService _mentorCourseUtilsService = locator<MentorCourseUtilsService>();

  Future<List<CourseType>> getCourseTypes() async {
    dynamic response = await _api.getHTTP(url: '/course_types');
    List<CourseType> courseTypes = [];
    if (response != null) {
      courseTypes = List<CourseType>.from(response.map((model) => CourseType.fromJson(model)));
    }
    return courseTypes;
  }  

  Future<CourseModel> getCourse() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/current');
    CourseModel course = CourseModel.fromJson(response);
    return course;
  }

  Future<CourseModel> getPreviousCourse() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/previous');
    CourseModel course = CourseModel.fromJson(response);
    return course;
  }  

  Future<NextLessonMentor> getNextLesson() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/next_lesson');
    NextLessonMentor nextLesson = NextLessonMentor.fromJson(response);
    return nextLesson;
  }  

  Future<List<MentorPartnershipScheduleItemModel>> getMentorPartnershipSchedule(String? courseId) async {
    dynamic response = await _api.getHTTP(url: '/courses/${courseId}/mentor_partnership_schedule');
    List<MentorPartnershipScheduleItemModel> mentorPartnershipSchedule = [];
    if (response != null) {
      mentorPartnershipSchedule = List<MentorPartnershipScheduleItemModel>.from(response.map((model) => MentorPartnershipScheduleItemModel.fromJson(model)));
    }
    return mentorPartnershipSchedule;
  }

  Future<CourseModel> addCourse(CourseModel? course, CourseType? selectedCourseType, Field? field, String subfieldId, Availability? availability, String meetingUrl) async {
    String dayOfWeek = availability?.dayOfWeek as String;
    String timeFrom = availability?.time?.from as String;
    List<Subfield> subfields = field?.subfields as List<Subfield>;
    subfields = subfields.where((subfield) => subfield.id == subfieldId).toList();
    field?.subfields = subfields;
    CourseModel course = CourseModel(
      type: selectedCourseType,
      startDateTime: _mentorCourseUtilsService.getCourseDateTime(dayOfWeek, timeFrom),
      mentors: [CourseMentor(field: field, meetingUrl: meetingUrl)]
    );
    Map<String, dynamic> response = await _api.postHTTP(url: '/courses/add', data: course.toJson());
    course = CourseModel.fromJson(response);
    return course;
  }

  Future<void> updateMentorPartnershipScheduleItem(String? id, String? mentorId) async {
    MentorPartnershipScheduleItemModel mentorPartnershipScheduleItem = MentorPartnershipScheduleItemModel(
      id: id,
      mentor: CourseMentor(id: mentorId)
    );
    await _api.putHTTP(url: '/mentor_partnership_schedule', data: mentorPartnershipScheduleItem.toJson());  
    return ;
  }

  Future<void> cancelCourse(String? id, String? reason) async {
    AttachedMessage attachedMessage = AttachedMessage(
      text: reason
    );
    await _api.putHTTP(url: '/courses/$id/cancel', data: attachedMessage.toJson());  
    return ;
  }

  Future<NextLessonMentor> cancelNextLesson(String? courseId, String? reason) async {
    AttachedMessage attachedMessage = AttachedMessage(
      text: reason
    );
    Map<String, dynamic> response = await _api.putHTTP(url: '/courses/$courseId/cancel_next_lesson', data: attachedMessage.toJson());  
    NextLessonMentor nextLesson = NextLessonMentor.fromJson(response);
    return nextLesson;
  }

  Future<Field> getField(String fieldId) async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/fields/$fieldId');
    Field field = Field.fromJson(response);
    return field;
  }

  Future<List<MentorWaitingRequest>> getMentorsWaitingRequests() async {
    dynamic response = await _api.getHTTP(url: '/mentors_waiting_requests');
    List<MentorWaitingRequest> mentorsWaitingRequests = [];
    if (response != null) {
      mentorsWaitingRequests = List<MentorWaitingRequest>.from(response.map((model) => MentorWaitingRequest.fromJson(model)));
    }
    return mentorsWaitingRequests;
  }
  
  Future<MentorWaitingRequest> getMentorWaitingRequest() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/mentors_waiting_requests/current');
    MentorWaitingRequest mentorWaitingRequest = MentorWaitingRequest.fromJson(response);
    return mentorWaitingRequest;
  }  

  Future<void> addMentorWaitingRequest(MentorWaitingRequest mentorWaitingRequest, CourseType? selectedCourseType) async {
    mentorWaitingRequest.courseType = selectedCourseType;    
    await _api.postHTTP(url: '/mentors_waiting_requests/add', data: mentorWaitingRequest.toJson());  
    return ;
  }

  Future<void> cancelMentorWaitingRequest() async {
    await _api.putHTTP(url: '/mentors_waiting_requests/cancel');  
    return ;
  }

  Future<MentorPartnershipRequestModel> getMentorPartnershipRequest() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/mentors_partnership_requests/current');
    MentorPartnershipRequestModel mentorPartnershipRequest = MentorPartnershipRequestModel.fromJson(response);
    return mentorPartnershipRequest;
  }
  
  Future<CourseModel> acceptMentorPartnershipRequest(String? id, String meetingUrl) async {
    CourseMentor mentor = CourseMentor(
      meetingUrl: meetingUrl
    );    
    Map<String, dynamic> response = await _api.postHTTP(url: '/mentors_partnership_requests/$id/accept', data: mentor.toJson()); 
    CourseModel course = CourseModel.fromJson(response); 
    return course;
  }  

  Future<void> rejectMentorPartnershipRequest(String? id, String? reason) async {
    AttachedMessage attachedMessage = AttachedMessage(
      text: reason
    );
    await _api.putHTTP(url: '/mentors_partnership_requests/$id/reject', data: attachedMessage.toJson());  
    return ;
  }

  Future<void> cancelMentorPartnershipRequest(String? id) async {
    await _api.putHTTP(url: '/mentors_partnership_requests/$id/cancel');  
    return ;
  }

  Future<void> updateMentorPartnershipRequest(String? id, MentorPartnershipRequestModel mentorPartnershipRequestModel) async {
    await _api.putHTTP(url: '/mentors_partnership_requests/$id/update', data: mentorPartnershipRequestModel.toJson());  
    return ;
  }  

  Future<void> setMeetingUrl(String? id, String meetingUrl) async {
    CourseMentor mentor = CourseMentor(
      meetingUrl: meetingUrl
    );    
    await _api.putHTTP(url: '/courses/$id/meeting_url', data: mentor.toJson());  
    return ;
  }

  Future<void> setWhatsAppGroupUrl(String? id, String? whatsAppGroupUrl) async {
    CourseModel course = CourseModel(
      whatsAppGroupUrl: whatsAppGroupUrl
    );    
    await _api.putHTTP(url: '/courses/$id/whatsapp_group_url', data: course.toJson());  
    return ;
  }

  Future<void> updateCourseNotes(String? id, String? notes) async {
    CourseModel course = CourseModel(
      notes: notes
    );    
    await _api.putHTTP(url: '/courses/$id/notes', data: course.toJson());  
    return ;
  }
}