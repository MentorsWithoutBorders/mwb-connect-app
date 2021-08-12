import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/notifications_settings_model.dart';

class NotificationsService {
  final ApiService _api = locator<ApiService>();

  Future<NotificationsSettings> getNotificationsSettings() async {
    http.Response response = await _api.getHTTP(url: '/notifications_settings');
    NotificationsSettings notificationsSettings;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      notificationsSettings = NotificationsSettings.fromJson(json);
    }
    return notificationsSettings;
  }

  Future updateNotificationsSettings(NotificationsSettings notificationsSettings) async {
    await _api.putHTTP(url: '/notifications_settings', data: notificationsSettings.toJson());  
    return ;
  }

}
