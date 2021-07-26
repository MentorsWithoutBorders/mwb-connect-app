import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/fcm_token_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class PushNotificationsService {
  final ApiService _api = locator<ApiService>();

  PushNotificationsService._();

  factory PushNotificationsService() => _instance;

  static final PushNotificationsService _instance = PushNotificationsService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // For iOS request permission first.
    _firebaseMessaging.requestPermission();

    await _firebaseMessaging.deleteToken();
    String token = await _firebaseMessaging.getToken();
    print("FirebaseMessaging token: $token");
    FCMToken fcmToken = FCMToken(token: token);
    _addFCMToken(fcmToken);
  }

  void _addFCMToken(FCMToken fcmToken) {
    _api.postHTTP(url: '/fcm_tokens', data: fcmToken.toJson());  
  }  
}