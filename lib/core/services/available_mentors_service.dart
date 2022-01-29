import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class AvailableMentorsService {
  final ApiService _api = locator<ApiService>();

  Future<List<User>> getAvailableMentors(User filter) async {
    dynamic response = await _api.postHTTP(url: '/available_mentors', data: filter.toJson());
    List<User> availableMentors = [];
    if (response != null) {
      availableMentors = List<User>.from(response.map((model) => User.fromJson(model)));      
    }    
    return availableMentors;
  }

  Future<List<Field>> getFields() async {
    dynamic response = await _api.getHTTP(url: '/available_mentors/fields');
    List<Field> fields = [];
    if (response != null) {
      fields = List<Field>.from(response.map((model) => Field.fromJson(model)));
    }
    return fields;
  }  

  Future<void> sendCustomLessonRequest(User? user) async {
    await _api.postHTTP(url: '/lesson_requests/send_custom_lesson_request', data: user?.toJson());
  }  

}