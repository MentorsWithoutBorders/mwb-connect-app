import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:quiver/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/timezone.dart';
import 'package:mwb_connect_app/core/models/received_notification_model.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/ui/views/onboarding/onboarding_view.dart';
import 'package:mwb_connect_app/ui/views/goals/goals_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

final GetIt getIt = GetIt.instance;

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

class RootView extends StatefulWidget {
  RootView({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final UserService _userService = locator<UserService>();
  final DownloadService _downloadService = locator<DownloadService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  AuthStatus _authStatus = AuthStatus.NOT_DETERMINED;
  dynamic _location;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _setPreferences();
    //_downloadService.getImages();
    _setUserStorage();
    _setCurrentUser();
    _setLocalNotifications().then((value) {
      _requestIOSPermissions();
      _configureDidReceiveLocalNotificationSubject();
      _configureSelectNotificationSubject();      
    });
  }

  void _setPreferences() {
    _downloadService.downloadLocales().then((value) {
      _downloadService.setPreferences();
    });    
  }

  Future<void> _setUserStorage() async {
    await _userService.setUserStorage();
  }      

  void _setCurrentUser() {
    widget.auth.getCurrentUser().then((User user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        _authStatus =
          user?.isAnonymous == true || user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });    
  }

  Future<void> _setLocalNotifications() async {
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
  
  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
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

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      print(payload);
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }  

  void loginCallback() {
    widget.auth.getCurrentUser().then((User user) {
      setState(() {
        _userId = user.uid.toString();
      });
    });
    setState(() {
      _authStatus = AuthStatus.LOGGED_IN;
    });
    _setPreferences();
  }

  void logoutCallback() {
    setState(() {
      _authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }
  
  Widget _showGoalsView(goalProvider) {
    return GoalsView(
      auth: widget.auth,
      logoutCallback: logoutCallback,
    );
  }

  Widget _buildWaitingScreen() {
    return Stack(
      children: <Widget>[
        BackgroundGradient(),
        Loader()
      ]
    );
  }

  Future<void> _showDailyAtTime() async {
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

  void _sendAnalyticsEvent() {
    _analyticsService.sendEvent(
      eventName: 'root',
      properties: {
        'p1': 'property1',
        'p2': 'property2'
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final GoalsViewModel goalProvider = Provider.of<GoalsViewModel>(context);
    final NotificationsViewModel notificationProvider = Provider.of<NotificationsViewModel>(context);

    if (notificationProvider.notificationSettingsUpdated) {
      _showDailyAtTime();
    }
    print('this is rootview');
    //_downloadService.showFiles();

    _sendAnalyticsEvent();

    switch (_authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return OnboardingView(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (isNotEmpty(_userId)) {
          return _showGoalsView(goalProvider);
        } else
          return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}