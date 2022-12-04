import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/in_app_message_model.dart';

class MentorCourseService {
  final ApiService _api = locator<ApiService>();

  Future<List<CourseType>> getCoursesTypes() async {
    dynamic response = await _api.getHTTP(url: '/courses_types');
    List<CourseType> coursesTypes = [];
    if (response != null) {
      coursesTypes = List<CourseType>.from(response.map((model) => CourseType.fromJson(model)));
    }
    return coursesTypes;
  }  

  Future<Course> getCurrentCourse() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/current');
    Course course = Course.fromJson(response);
    return course;
  }

  Future<void> addCourse(Course course) async {
    await _api.postHTTP(url: '/courses', data: course.toJson());  
    return ;
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
  
  Future<MentorWaitingRequest> getCurrentMentorWaitingRequest() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/mentors_waiting_requests/current');
    MentorWaitingRequest mentorWaitingRequest = MentorWaitingRequest.fromJson(response);
    return mentorWaitingRequest;
  }  

  Future<void> addMentorWaitingRequest(MentorWaitingRequest mentorWaitingRequest) async {
    await _api.postHTTP(url: '/mentors_waiting_requests', data: mentorWaitingRequest.toJson());  
    return ;
  }

  Future<void> cancelMentorWaitingRequest(String? id) async {
    await _api.putHTTP(url: '/mentors_waiting_requests/$id/cancel', data: {});  
    return ;
  }

  Future<MentorPartnershipRequestModel> getCurrentMentorPartnershipRequest() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/mentors_partnership_requests/current');
    MentorPartnershipRequestModel mentorPartnershipRequestModel = MentorPartnershipRequestModel.fromJson(response);
    return mentorPartnershipRequestModel;
  }
  
  Future<void> sendMentorPartnershipRequest(MentorPartnershipRequestModel mentorPartnershipRequestModel) async {
    await _api.postHTTP(url: '/mentors_partnership_requests', data: mentorPartnershipRequestModel.toJson());  
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
    await _api.postHTTP(url: '/mentors_partnership_requests/$id/cancel', data: {});  
    return ;
  }

  Future<void> updateMentorPartnershipRequest(String? id, MentorPartnershipRequestModel mentorPartnershipRequestModel) async {
    await _api.postHTTP(url: '/mentors_partnership_requests/$id/update', data: mentorPartnershipRequestModel.toJson());  
    return ;
  }  
}