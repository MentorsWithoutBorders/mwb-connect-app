import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/timezone.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/services/push_notifications_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/timezone_model.dart';

class LoginSignupViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  final PushNotificationsService pushNotificationsService = locator<PushNotificationsService>();

  Future<String> signUp(User user) async {
    Uuid uuid = Uuid();
    user.id = uuid.v4();
    user.timeZone = await getTimeZone();
    try {
      String userId = await _authService.signUp(user);
      await _initPushNotifications();
      return userId;
    } catch(error) {
      throw(error);
    }
  }

  Future<TimeZoneModel> getTimeZone() async {
    final TimeZone timeZone = TimeZone();
    final String timeZoneName = await timeZone.getTimeZoneName();
    DateTime now = DateTime.now();
    String offset = now.timeZoneOffset.toString();
    List<String> offsetList = offset.split(':');
    offset = offsetList[0] + ':' + offsetList[1];
    return TimeZoneModel(abbreviation: now.timeZoneName, name: timeZoneName, offset: offset);
  }

  Future<String> login(User user) async {
    try {
      String userId = await _authService.login(user);
      await _initPushNotifications();
      return userId;
    } catch(error) {
      throw(error);
    }
  }

  Future<void> _initPushNotifications() async {
    await pushNotificationsService.init();
  }    
}
