import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/notifications_settings_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class NotificationsService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  Future<NotificationsSettings> getNotificationsSettings() async {
    String userId = _storageService.userId;
    http.Response response = await _api.getHTTP(url: '/users/$userId/notifications_settings');
    NotificationsSettings notificationsSettings;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      notificationsSettings = NotificationsSettings.fromJson(json);
    }
    return notificationsSettings;
  }

  Future updateNotificationsSettings(NotificationsSettings notificationsSettings) async {
    String userId = _storageService.userId;    
    await _api.putHTTP(url: '/users/$userId/notifications_settings', data: notificationsSettings.toJson());  
    return ;
  }

}
