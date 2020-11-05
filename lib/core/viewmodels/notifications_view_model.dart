import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/notification_settings_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class NotificationsViewModel extends ChangeNotifier {
  Api _api = locator<Api>();
  LocalStorageService _storageService = locator<LocalStorageService>();
  bool notificationSettingsUpdated = true;

  Future<NotificationSettings> getNotificationSettings() async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'notifications', isForUser: true, id: 'settings');
    if (doc.exists) {
      return NotificationSettings.fromMap(doc.data, doc.documentID);
    } else {
      NotificationSettings data = NotificationSettings(enabled: _storageService.notificationsEnabled, time: _storageService.notificationsTime);
      await _api.setDocument(path: 'notifications', isForUser: true, data: data.toJson(), id: 'settings');
      return data;
    }
  }

  Future updateNotificationSettings(NotificationSettings data) async {
    notificationSettingsUpdated = true;
    notifyListeners();
    await _api.updateDocument(path: 'notifications', isForUser: true, data: data.toJson(), id: 'settings');
    return ;
  }

}
