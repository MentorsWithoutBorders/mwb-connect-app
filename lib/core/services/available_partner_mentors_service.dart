import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class AvailablePartnerMentorsService {
  final ApiService _api = locator<ApiService>();

  Future<List<User>> getAvailablePartnerMentors(User filter, int pageNumber) async {
    dynamic response = await _api.postHTTP(url: '/mentors_waiting_requests?page=$pageNumber', data: filter.toJson());
    List<User> availablePartnerMentors = [];
    if (response != null) {
      availablePartnerMentors = List<User>.from(response.map((model) => User.fromJson(model)));      
    }    
    return availablePartnerMentors;
  }
}