import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/core/models/update_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class UpdateAppService {
  final ApiService _api = locator<ApiService>();

  Future<Update> getCurrentVersion() async {
    http.Response response = await _api.getHTTP(url: '/updates');
    Update update;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      update = Update.fromJson(json);
    }
    return update;
  }
}
