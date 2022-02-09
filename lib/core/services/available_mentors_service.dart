import 'package:mwb_connect_app/core/models/lesson_request_result_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class AvailableMentorsService {
  final ApiService _api = locator<ApiService>();

  Future<List<User>> getAvailableMentors(User filter, int pageNumber) async {
    dynamic response = await _api.postHTTP(url: '/available_mentors?page=$pageNumber', data: filter.toJson());
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
}