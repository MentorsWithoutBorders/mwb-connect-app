import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/in_app_message_model.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_utils_service.dart';

class MentorCourseApiService {
  final ApiService _api = locator<ApiService>();
  final UserService _userService = locator<UserService>();
  final MentorCourseUtilsService _mentorCourseUtilsService = locator<MentorCourseUtilsService>();

  Future<List<CourseType>> getCoursesTypes() async {
    dynamic response = await _api.getHTTP(url: '/courses_types');
    List<CourseType> coursesTypes = [];
    if (response != null) {
      coursesTypes = List<CourseType>.from(response.map((model) => CourseType.fromJson(model)));
    }
    return coursesTypes;
  }  

  Future<CourseModel> getCourse() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/current');
    CourseModel course = CourseModel.fromJson(response);
    return course;
  }

  Future<CourseModel> addCourse(CourseModel? course, CourseType? selectedCourseType, Availability? availability, String meetingUrl) async {
    String dayOfWeek = availability?.dayOfWeek as String;
    String timeFrom = availability?.time?.from as String;
    CourseModel course = CourseModel();
    course.type = selectedCourseType;
    course.startDateTime = _mentorCourseUtilsService.getCourseDateTime(dayOfWeek, timeFrom);
    course.mentors = [CourseMentor(meetingUrl: meetingUrl)];
    Map<String, dynamic> response = await _api.postHTTP(url: '/courses', data: course.toJson());
    course = CourseModel.fromJson(response);
    return course;
  }

  Future<void> cancelCourse(String? id, String? reason) async {
    InAppMessage inAppMessage = InAppMessage(
      text: reason
    );
    await _api.putHTTP(url: '/courses/$id/cancel', data: inAppMessage.toJson());  
    return ;
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
    await _api.postHTTP(url: '/mentors_waiting_requests', data: mentorWaitingRequest.toJson());  
    return ;
  }

  Future<void> cancelMentorWaitingRequest(String? id) async {
    await _api.putHTTP(url: '/mentors_waiting_requests/$id/cancel');  
    return ;
  }

  Future<MentorPartnershipRequestModel> getMentorPartnershipRequest() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/mentors_partnership_requests/current');
    MentorPartnershipRequestModel mentorPartnershipRequestModel = MentorPartnershipRequestModel.fromJson(response);
    return mentorPartnershipRequestModel;
  }
  
  Future<void> sendMentorPartnershipRequest(MentorPartnershipRequestModel mentorPartnershipRequest, CourseType? selectedCourseType) async {
    mentorPartnershipRequest.mentor = (await _userService.getUserDetails()) as CourseMentor;
    mentorPartnershipRequest.courseType = selectedCourseType;    
    await _api.postHTTP(url: '/mentors_partnership_requests', data: mentorPartnershipRequest.toJson());  
    return ;
  }
  
  Future<void> acceptMentorPartnershipRequest(String? id, String meetingUrl) async {
    CourseMentor mentor = CourseMentor(
      meetingUrl: meetingUrl
    );    
    await _api.postHTTP(url: '/mentors_partnership_requests/$id/accept', data: mentor.toJson());  
    return ;
  }  

  Future<void> rejectMentorPartnershipRequest(String? id, String? reason) async {
    InAppMessage inAppMessage = InAppMessage(
      text: reason
    );
    await _api.putHTTP(url: '/mentors_partnership_requests/$id/reject', data: inAppMessage.toJson());  
    return ;
  }

  Future<void> cancelMentorPartnershipRequest(String? id) async {
    await _api.postHTTP(url: '/mentors_partnership_requests/$id/cancel');  
    return ;
  }

  Future<void> updateMentorPartnershipRequest(String? id, MentorPartnershipRequestModel mentorPartnershipRequestModel) async {
    await _api.postHTTP(url: '/mentors_partnership_requests/$id/update', data: mentorPartnershipRequestModel.toJson());  
    return ;
  }  

  Future<void> updateMeetingUrl(String? id, String meetingUrl) async {
    CourseMentor mentor = CourseMentor(
      meetingUrl: meetingUrl
    );    
    await _api.postHTTP(url: '/courses/$id/update_meeting_url', data: mentor.toJson());  
    return ;
  }
}