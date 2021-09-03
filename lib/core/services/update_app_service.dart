import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/core/models/app_version_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class UpdateAppService {
  final ApiService _api = locator<ApiService>();

  Future<void> sendAppVersion(AppVersion currentAppVersion) async {
    _api.postHTTP(url: '/app_versions', data: currentAppVersion.toJson());  
  }  

  Future<AppVersion> getCurrentVersion() async {
    http.Response response = await _api.getHTTP(url: '/updates');
    var json = jsonDecode(response.body);
    AppVersion appVersion = AppVersion.fromJson(json);
    return appVersion;
  }
}
