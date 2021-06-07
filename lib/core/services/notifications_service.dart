import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/notification_settings_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class NotificationsService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  Future<NotificationSettings> getNotificationSettings() async {
    String userId = _storageService.userId;
    http.Response response = await _api.getHTTP(url: '/$userId/notifications_settings');
    NotificationSettings notificationSettings;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      notificationSettings = NotificationSettings.fromJson(json);
    }
    return notificationSettings;
  }

  Future updateNotificationSettings(NotificationSettings notificationSettings) async {
    String userId = _storageService.userId;    
    await _api.putHTTP(url: '/$userId/notifications_settings', data: notificationSettings.toJson());  
    return ;
  }

}
