import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class AvailablePartnerMentorsService {
  final ApiService _api = locator<ApiService>();

  Future<List<MentorWaitingRequest>> getMentorsWaitingRequests(User filter, int pageNumber) async {
    dynamic response = await _api.getHTTP(url: '/mentors_waiting_requests?page=$pageNumber', data: filter.toJson());
    List<MentorWaitingRequest> mentorsWaitingRequests = [];
    if (response != null) {
      mentorsWaitingRequests = List<MentorWaitingRequest>.from(response.map((model) => MentorWaitingRequest.fromJson(model)));      
    }    
    return mentorsWaitingRequests;
  }
}