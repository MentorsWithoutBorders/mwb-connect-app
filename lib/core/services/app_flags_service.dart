import 'dart:async';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/app_flags_model.dart';

class AppFlagsService {
  final ApiService _api = locator<ApiService>();

  Future<AppFlags> getAppFlags() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/app_flags');
    AppFlags appFlags = AppFlags.fromJson(response);
    return appFlags;
  }

}
