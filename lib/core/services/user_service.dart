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
  final Api _api = locator<Api>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final NotificationsService _notificationsService = locator<NotificationsService>(); 

  Future<void> setUserStorage({User user}) async {
    if (user?.id != null) {
      _storageService.userId = user.id;
      _storageService.userEmail = user.email;
      final User userDetails = await getUserDetails();
      if (isNotEmpty(userDetails.name)) {
        _storageService.userName = userDetails.name;
      }
      if (userDetails.isMentor != null) {
        _storageService.isMentor = userDetails.isMentor;
      } else {
        _storageService.isMentor = false;
      }
      // Get notifications settings
      final NotificationSettings notificationSettings = await _notificationsService.getNotificationSettings();
      if (notificationSettings != null) {
        _storageService.notificationsEnabled = notificationSettings.enabled;
      }
      if (notificationSettings != null && notificationSettings.time != null) {
        _storageService.notificationsTime = notificationSettings.time;
      }
    }
  }
  
  Future<void> setUserDetails(User user) async {
    await _api.setDocument(path: 'profile', isForUser: true, data: user.toJson(), id: 'details');
    setUserStorage(user: user);
  }

  Future<User> getUserDetails() async {
    final DocumentSnapshot doc = await _api.getDocumentById(path: 'profile', isForUser: true, id: 'details');
    if (doc.exists) {
      return User.fromMap(doc.data(), _storageService.userId);
    } else {
      return User();
    }
  }

  Future<User> getDefaultUserDetails() async {
    final DocumentSnapshot doc = await _api.getDocumentById(path: 'user_default_profile', isForUser: false, id: 'details');
    if (doc.exists) {
      return User.fromMap(doc.data(), null);
    } else {
      return User();
    }
  }  
  
  Future<List<ApprovedUser>> fetchApprovedUsers() async {
    final QuerySnapshot result = await _api.getDataCollection(path: 'approved_users', isForUser: false);
    return result.docs
        .map((QueryDocumentSnapshot doc) => ApprovedUser.fromMap(doc.data(), null))
        .toList();
  }

  Future<ApprovedUser> checkApprovedUser(String email) async {
    final List<ApprovedUser> approvedUsers = await fetchApprovedUsers();
    for (final ApprovedUser user in approvedUsers) {
      if (user.email == email) {
        return user;
      }
    }
    return null;
  }
}