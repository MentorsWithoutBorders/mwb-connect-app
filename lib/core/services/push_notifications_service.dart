import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/push_notification_type.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/in_app_messages_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/core/models/fcm_token_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';

class PushNotificationsService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final InAppMessagesService _inAppMessagesService = locator<InAppMessagesService>();
  final LoggerService _loggerService = locator<LoggerService>();

  PushNotificationsService._();

  factory PushNotificationsService() => _instance;

  static final PushNotificationsService _instance = PushNotificationsService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  Future<void> init() async {
    if (_storageService.userId != null) {
      // For iOS request permission first.
      if (_storageService.isFCMPermissionRequested != true) {
        _storageService.isFCMPermissionRequested = true;
        _loggerService.addLogEntry('requesting permission');
        _firebaseMessaging.requestPermission();
      }
      String token = await _firebaseMessaging.getToken() as String;
      print('FirebaseMessaging token: $token');
      FCMToken fcmToken = FCMToken(token: token);
      await _addFCMToken(fcmToken);
      _loggerService.addLogEntry('token added: ' + token);
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
        String notification = '';
        if (event.notification != null && event.notification?.body != null) {
          notification = event.notification?.body as String;
        }
        _loggerService.addLogEntry('PN pressed: ' + notification);
        showPushNotification(event: event, isOpenApp: true);
      });       
      FirebaseMessaging.onMessage.listen((RemoteMessage event) {
        String notification = '';
        if (event.notification != null && event.notification?.body != null) {
          notification = event.notification?.body as String;
        }        
        _loggerService.addLogEntry('attempt show PN inside app: ' + notification);
        showPushNotification(event: event, isOpenApp: false);
      }); 
    }
  }

  PushNotificationType _getPushNotificationType(String type) {
    PushNotificationType pushNotificationType = PushNotificationType.normal;
    PushNotificationType.values.forEach((PushNotificationType value) {
      var typeInt = int.tryParse(type);
      if (typeInt == null) {
        typeInt = 0;
      }
      if (PushNotificationType.values[typeInt] == value) {
        pushNotificationType = value;
      }
    });
    return pushNotificationType;
  }

  void showPushNotification({required RemoteMessage event, required bool isOpenApp}) {
    if (_shouldShowPushNotification()) {
      switch (_getPushNotificationType(event.data['type'])) {
        case PushNotificationType.normal:
          if (!isOpenApp) {
            _showNormalPushNotification(event);
          }
          break;
        case PushNotificationType.request:
          if (!isOpenApp) {
            _showRequestPushNotification(event);
          }
          break;
        default:
          if (!isOpenApp) {
            _showNormalPushNotification(event);
          }
      }
      final DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
      final DateTime now = DateTime.now();
      _storageService.lastPNShownDateTime = dateFormat.format(now);
    }
  }

  void _showNormalPushNotification(event) {
    if (event != null && event.notification.body.isNotEmpty) {
      _inAppMessagesService.deleteInAppMessage();
      _loggerService.addLogEntry('showing PN inside app: ' + event.notification.body);
      showDialog(
        context: NavigationService.instance.getCurrentContext() as BuildContext,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => _reloadApp(context),
            child: AnimatedDialog(
              widgetInside: NotificationDialog(
                text: event.notification.body, 
                buttonText: 'common.ok'.tr(),
                shouldReload: true
              )
            )
          );
        }
      );
    }
  }

  void _showRequestPushNotification(event) {
    if (event != null && event.notification.body.isNotEmpty) {
      _inAppMessagesService.deleteInAppMessage();
      _loggerService.addLogEntry('showing PN inside app: ' + event.notification.body);
      showDialog(
        context: NavigationService.instance.getCurrentContext() as BuildContext,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => _reloadApp(context),
            child: AnimatedDialog(
              widgetInside: NotificationDialog(
                text: event.notification.body, 
                buttonText: 'common.show_request'.tr(),
                shouldReload: true
              )
            )
          );
        }
      );
    }    
  }
  
  bool _shouldShowPushNotification() {
    final DateTime now = DateTime.now();
    DateTime lastPNShownDateTime = DateTime.now();
    if (_storageService.lastPNShownDateTime != null) {
      lastPNShownDateTime = DateTime.parse(_storageService.lastPNShownDateTime as String);
    }
    if (_storageService.lastPNShownDateTime == null || now.difference(lastPNShownDateTime).inSeconds >= 3) {
      return true;
    } else {
      return false;
    }       
  }  

  Future<void> deleteFCMToken() async {
    await _firebaseMessaging.deleteToken();        
  }  

  Future<bool> _reloadApp(BuildContext context) async {
    Phoenix.rebirth(context);
    return true;
  }  

  Future<void> _addFCMToken(FCMToken fcmToken) async {
    await _api.postHTTP(url: '/fcm_tokens', data: fcmToken.toJson());  
  }  
}