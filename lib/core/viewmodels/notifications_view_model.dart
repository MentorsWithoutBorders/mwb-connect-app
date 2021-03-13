import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/notifications_service.dart';
import 'package:mwb_connect_app/core/models/notification_settings_model.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationsService _notificationsService = locator<NotificationsService>();
  bool notificationSettingsUpdated = true;

  Future<void> updateNotificationSettings(NotificationSettings data) async {
    notificationSettingsUpdated = true;
    notifyListeners();
    await _notificationsService.updateNotificationSettings(data);
    return ;
  }

}
