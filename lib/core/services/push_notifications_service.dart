import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mwb_connect_app/utils/push_notification_type.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/core/models/fcm_token_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/learned_today_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/taught_today_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';

class PushNotificationsService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  PushNotificationsService._();

  factory PushNotificationsService() => _instance;

  static final PushNotificationsService _instance = PushNotificationsService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  Future<void> init() async {
    // For iOS request permission first.    
    _firebaseMessaging.requestPermission();
    await deleteFCMToken();
    String token = await _firebaseMessaging.getToken();
    print("FirebaseMessaging token: $token");
    FCMToken fcmToken = FCMToken(token: token);
    await _addFCMToken(fcmToken);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      showPushNotification(event);
    });       
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      showPushNotification(event);
    }); 
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

  void showPushNotification(RemoteMessage event) {
    switch (_getPushNotificationType(event.data['type'])) {
      case PushNotificationType.normal:
        _showNormalPushNotification(event);
        break;
      case PushNotificationType.afterLesson:
        _showAfterLessonPushNotification();
        break;
      default:
        _showNormalPushNotification(event);       
    }
  }

  void _showNormalPushNotification(event) {
    if (event != null && event.notification.body.isNotEmpty) {
      showDialog(
        context: NavigationService.instance.getCurrentContext(),
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => _reloadApp(context),
            child: AnimatedDialog(
              widgetInside: NotificationDialog(text: event.notification.body, shouldReload: true)
            )
          );
        }
      );
    }    
  }

  void _showAfterLessonPushNotification() {
    bool isMentor = _storageService.isMentor;
    if (isMentor) {
      showDialog(
        context: NavigationService.instance.getCurrentContext(),
        builder: (_) => Center(
          child: AnimatedDialog(
            widgetInside: TaughtTodayDialog()
          ),
        ),
      );
    } else {
      showDialog(
        context: NavigationService.instance.getCurrentContext(),
        builder: (_) => Center(
          child: AnimatedDialog(
            widgetInside: LearnedTodayDialog()
          ),
        ),
      );      
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