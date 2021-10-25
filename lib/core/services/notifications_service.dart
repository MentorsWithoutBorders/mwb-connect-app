import 'dart:async';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/notifications_settings_model.dart';

class NotificationsService {
  final ApiService _api = locator<ApiService>();

  Future<NotificationsSettings> getNotificationsSettings() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/notifications_settings');
    NotificationsSettings notificationsSettings = NotificationsSettings.fromJson(response);
    return notificationsSettings;
  }

  Future updateNotificationsSettings(NotificationsSettings notificationsSettings) async {
    await _api.putHTTP(url: '/notifications_settings', data: notificationsSettings.toJson());  
    return ;
  }

}
