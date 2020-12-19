import 'package:quiver/strings.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/notification_settings_model.dart';
import 'package:mwb_connect_app/core/viewmodels/users_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class UserService {
  setUserStorage() async {
    LocalStorageService storageService = locator<LocalStorageService>();    
    // Get user details
    UsersViewModel usersViewModel = locator<UsersViewModel>();
    User user = await usersViewModel.getUserDetails();
    if (user != null) {
      if (isNotEmpty(user.name)) {
        storageService.userName = user.name;
      }
      if (isNotEmpty(user.email)) {
        storageService.userEmail = user.email;
      }
    }
    // Get notifications settings
    NotificationsViewModel notificationsViewModel = locator<NotificationsViewModel>();
    NotificationSettings notificationSettings = await notificationsViewModel.getNotificationSettings();
    if (notificationSettings != null) {
      storageService.notificationsEnabled = notificationSettings.enabled;
    }
    if (notificationSettings != null && notificationSettings.time != null) {
      storageService.notificationsTime = notificationSettings.time;
    }      
  }  
}