import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/notifications_settings_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/notifications_service.dart';

class UserService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final NotificationsService _notificationsService = locator<NotificationsService>(); 

  Future<void> setUserStorage({User user}) async {
    if (user?.id != null) {
      _storageService.userId = user.id;
      _storageService.userEmail = user.email;
      if (isNotEmpty(user.name)) {
        _storageService.userName = user.name;
      }      
      if (user.isMentor != null) {
        _storageService.isMentor = user.isMentor;
        if (!user.isMentor && user.field.subfields[0] != null) {
          _storageService.subfieldId = user.field.subfields[0].id;
        }
      }        
      if (user.registeredOn != null) {
        _storageService.registeredOn = user.registeredOn.toString();
      }      
      // Get notifications settings
      final NotificationsSettings notificationsSettings = await _notificationsService.getNotificationsSettings();
      if (notificationsSettings != null) {
        _storageService.notificationsEnabled = notificationsSettings.enabled;
      }
      if (notificationsSettings != null && notificationsSettings.time != null) {
        _storageService.notificationsTime = notificationsSettings.time;
      }
    }
  }

  Future<User> getUserDetails() async {
    http.Response response = await _api.getHTTP(url: '/user');
    User user;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      user = User.fromJson(json);
    }
    return user;
  }

  Future<void> setUserDetails(User user) async {
    _api.putHTTP(url: '/user', data: user.toJson());
  }  
}