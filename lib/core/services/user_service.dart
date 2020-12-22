import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/strings.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/approved_user_model.dart';
import 'package:mwb_connect_app/core/models/notification_settings_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/notifications_service.dart';

class UserService {
  Api _api = locator<Api>();
  LocalStorageService storageService = locator<LocalStorageService>();
  NotificationsService _notificationsService = locator<NotificationsService>(); 

  setUserStorage({String userId, String userName, String userEmail}) async { 
    if (storageService.userId == null) {
      storageService.userId = userId;
      storageService.userEmail = userEmail;
      if (userName != null) {
        storageService.userName = userName;
      } else {
        // Get user details
        User user = await getUserDetails();
        if (user != null) {
          if (isNotEmpty(user.name)) {
            storageService.userName = user.name;
          }
        }
      }
    }
    // Get notifications settings
    NotificationSettings notificationSettings = await _notificationsService.getNotificationSettings();
    if (notificationSettings != null) {
      storageService.notificationsEnabled = notificationSettings.enabled;
    }
    if (notificationSettings != null && notificationSettings.time != null) {
      storageService.notificationsTime = notificationSettings.time;
    }      
  }
  
  setUserDetails(User data) async {
    await _api.setDocument(path: 'profile', isForUser: true, data: data.toJson(), id: 'details');
  }

  Future<User> getUserDetails() async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'profile', isForUser: true, id: 'details');
    if (doc.exists) {
      return User.fromMap(doc.data, doc.documentID);
    } else {
      return User();
    }
  }
  
  Future<List<ApprovedUser>> fetchApprovedUsers() async {
    QuerySnapshot result = await _api.getDataCollection(path: 'approved_users', isForUser: false);
    return result.documents
        .map((doc) => ApprovedUser.fromMap(doc.data, doc.documentID))
        .toList();
  }    
}