import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/subjects.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/timezone.dart';
import 'package:mwb_connect_app/core/models/received_notification_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';

class RootViewModel extends ChangeNotifier {
  final UserService _userService = locator<UserService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final DownloadService _downloadService = locator<DownloadService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
  final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();
  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();
  NotificationAppLaunchDetails notificationAppLaunchDetails;
  dynamic _location; 

  Future<void> setUserStorage() async {
    await _userService.setUserStorage();
  }
  
  void setPreferences() {
    _downloadService.downloadLocales().then((value) {
      _downloadService.setPreferences();
    });    
  }

  Future<void> setLocalNotifications() async {
    notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      selectNotificationSubject.add(payload);
    });    
  }
  
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void configureDidReceiveLocalNotificationSubject(BuildContext context) {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                print(receivedNotification.payload);
              },
            )
          ],
        ),
      );
    });
  }

  void configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      print(payload);
    });
  }

  Future<void> showDailyAtTime() async {
    if (_storageService.notificationsEnabled) {
      final String notificationTitle = 'daily_notification.title'.tr();
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'MWB Connect',
          'MWB Connect notifications',
          'Your MWB Connect daily reminders');
      const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        notificationTitle,
        null,
        await _nextInstanceOfNotificationsTime(),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);            
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  Future<tz.TZDateTime> _nextInstanceOfNotificationsTime() async {
    final List<String> notificationsTime = _storageService.notificationsTime.split(':');
    final Time time = Time(int.parse(notificationsTime[0]), int.parse(notificationsTime[1]), 0);
    await _setTimeZone();
    final tz.TZDateTime now = tz.TZDateTime.now(_location);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(_location, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
  
  Future<void> _setTimeZone() async {
    final TimeZone timeZone = TimeZone();
    final String timeZoneName = await timeZone.getTimeZoneName();
    _location = await timeZone.getLocation(timeZoneName);    
  }

  void getImages() {
    _downloadService.getImages();    
  }  

  void sendAnalyticsEvent() {
    _analyticsService.sendEvent(
      eventName: 'root',
      properties: {
        'p1': 'property1',
        'p2': 'property2'
      }
    );
  }
}
