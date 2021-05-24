import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/notification_settings_model.dart';
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
      } else {
        _storageService.isMentor = false;
      }
      // // Get notifications settings
      // final NotificationSettings notificationSettings = await _notificationsService.getNotificationSettings();
      // if (notificationSettings != null) {
      //   _storageService.notificationsEnabled = notificationSettings.enabled;
      // }
      // if (notificationSettings != null && notificationSettings.time != null) {
      //   _storageService.notificationsTime = notificationSettings.time;
      // }
    }
  }
  
  Future<void> setUserDetails(User user) async {
    // await _api.setDocument(path: 'profile', isForUser: true, data: user.toJson(), id: 'details');
    // setUserStorage(user: user);
  }

  Future<User> getUserDetails() async {
    String userId = _storageService.userId;
    http.Response response = await _api.getHTTP(url: '/users/$userId');
    User user;
    if (response != null) {
      var json = jsonDecode(response.body);
      user = User.fromJson(json);
    }
    return user;

    // final DocumentSnapshot doc = await _api.getDocumentById(path: 'profile', isForUser: true, id: 'details');
    // if (doc.exists) {
    //   return User.fromMap(doc.data(), _storageService.userId);
    // } else {
    //   return User();
    // }
  }
}