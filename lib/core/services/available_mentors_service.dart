import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';

class AvailableMentorsService {
  final ApiService _api = locator<ApiService>();

  Future<List<User>> getAvailableMentors() async {
    dynamic response = await _api.getHTTP(url: '/available_mentors');
    List<User> availableMentors = [];
    if (response != null) {
      availableMentors = List<User>.from(response.map((model) => User.fromJson(model)));      
    }    
    return availableMentors;
  }

  Future<void> sendCustomLessonRequest(User? user) async {
    await _api.postHTTP(url: '/lesson_requests/send_custom_lesson_request', data: user?.toJson());
  }  

}