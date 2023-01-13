import 'package:intl/intl.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class MentorsWaitingRequestsApiService {
  final ApiService _api = locator<ApiService>();

  Future<List<MentorWaitingRequest>> getMentorsWaitingRequests(CourseType? courseType, MentorWaitingRequest filter, int pageNumber) async {
    dynamic response = await _api.postHTTP(url: '/mentors_waiting_requests?page=$pageNumber', data: filter.toJson());
    List<MentorWaitingRequest> mentorsWaitingRequests = [];
    if (response != null) {
      mentorsWaitingRequests = List<MentorWaitingRequest>.from(response.map((model) => MentorWaitingRequest.fromJson(model)));      
    }    
    return mentorsWaitingRequests;
  }

  Future<MentorPartnershipRequestModel> sendMentorPartnershipRequest(CourseMentor mentor, CourseMentor? partnerMentor, CourseType? selectedCourseType, String courseDayOfWeek, String courseStartTime) async {
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormat, 'en');
    DateTime utcDateTime = UtilsAvailabilities.convertDayAndTimeToUtc(courseDayOfWeek, courseStartTime);
    MentorPartnershipRequestModel mentorPartnershipRequest = MentorPartnershipRequestModel(
      mentor: mentor,
      partnerMentor: partnerMentor as CourseMentor,
      courseType: selectedCourseType,
      courseDayOfWeek: dayOfWeekFormat.format(utcDateTime),
      courseStartTime: timeFormat.format(utcDateTime)
    );    
    
    Map<String, dynamic> response = await _api.postHTTP(url: '/mentors_partnership_requests', data: mentorPartnershipRequest.toJson());  
    mentorPartnershipRequest = MentorPartnershipRequestModel.fromJson(response);
    return mentorPartnershipRequest;
  }
}