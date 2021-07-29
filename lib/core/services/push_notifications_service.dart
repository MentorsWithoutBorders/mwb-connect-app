import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/fcm_token_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';

class PushNotificationsService {
  final ApiService _api = locator<ApiService>();

  PushNotificationsService._();

  factory PushNotificationsService() => _instance;

  static final PushNotificationsService _instance = PushNotificationsService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  Future<void> init({bool isLogin}) async {
    // For iOS request permission first.    
    _firebaseMessaging.requestPermission();
    if (isLogin) {
      deleteFCMToken();
    }
    String token = await _firebaseMessaging.getToken();
    print("FirebaseMessaging token: $token");
    FCMToken fcmToken = FCMToken(token: token);
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      if (event.notification.body.isNotEmpty) {
        showDialog(
          context: NavigationService.instance.getCurrentContext(),
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () => _reloadApp(context),
              child: AnimatedDialog(
                widgetInside: NotificationDialog(text: event.notification.body)
              )
            );
          }
        );
      }     
    });
    if (isLogin) {
      _addFCMToken(fcmToken);
    }
  }

  Future<void> deleteFCMToken() async {
    await _firebaseMessaging.deleteToken();        
  }  

  Future<bool> _reloadApp(BuildContext context) async {
    Phoenix.rebirth(context);
    return true;
  }  

  void _addFCMToken(FCMToken fcmToken) {
    _api.postHTTP(url: '/fcm_tokens', data: fcmToken.toJson());  
  }  
}