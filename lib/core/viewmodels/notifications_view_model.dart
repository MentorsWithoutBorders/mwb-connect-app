import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/notifications_service.dart';
import 'package:mwb_connect_app/core/models/notifications_settings_model.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationsService _notificationsService = locator<NotificationsService>();
  NotificationsSettings? notificationsSettings;
  bool notificationsSettingsUpdated = true;

  Future<void> getNotificationsSettings() async {
    notificationsSettings = await _notificationsService.getNotificationsSettings();
  }  

  Future<void> updateNotificationsSettings(NotificationsSettings notificationsSettings) async {
    notificationsSettingsUpdated = true;
    notifyListeners();
    await _notificationsService.updateNotificationsSettings(notificationsSettings);
    return ;
  }

}
