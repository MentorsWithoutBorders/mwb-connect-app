import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:mwb_connect_app/core/services/authentication_service_old.dart';
import 'package:mwb_connect_app/core/viewmodels/root_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/ui/views/onboarding/onboarding_view.dart';
import 'package:mwb_connect_app/ui/views/goals/goals_view.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/connect_with_mentor_view.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/lesson_request_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

final GetIt getIt = GetIt.instance;

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootView extends StatefulWidget {
  const RootView({Key key, this.auth})
    : super(key: key);   

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  NotificationsViewModel _notificationsProvider;
  RootViewModel _rootProvider;
  AuthStatus _authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = '';

  @override
  void didChangeDependencies() {
    _rootProvider = Provider.of<RootViewModel>(context);
    _setCurrentUser();    
    _setUserStorage();
    _setPreferences();
    // _getImages();
    _setLocalNotifications();
    super.didChangeDependencies();
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

  void _setPreferences() {
    _rootProvider.setPreferences();   
  }

  Future<void> _setUserStorage() async {
    await _rootProvider.setUserStorage();
  }

  void _getImages() {
    _rootProvider.getImages();    
  }

  void _setLocalNotifications() {
    _rootProvider.setLocalNotifications().then((value) {
      _rootProvider.requestIOSPermissions();
      _rootProvider.configureDidReceiveLocalNotificationSubject(context);
      _rootProvider.configureSelectNotificationSubject();      
    });    
  }

  @override
  void dispose() {
    _rootProvider.didReceiveLocalNotificationSubject.close();
    _rootProvider.selectNotificationSubject.close();
    super.dispose();
  }  

  void _loginCallback() {
    // widget.auth.getCurrentUser().then((User user) {
    //   setState(() {
    //     _userId = user.uid.toString();
    //   });
    // });
    setState(() {
      _authStatus = AuthStatus.LOGGED_IN;
    });
    //_setPreferences();
  }

  void _logoutCallback() {
    setState(() {
      _authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }
  
  Widget _showGoalsView() {
    return GoalsView(
      auth: widget.auth,
      logoutCallback: _logoutCallback,
    );
  }

  Widget _showConnectWithMentorView() {
    return ConnectWithMentorView(
      auth: widget.auth,
      logoutCallback: _logoutCallback,
    );
  }
  
  Widget _showLessonRequestView() {
    return LessonRequestView(
      auth: widget.auth,
      logoutCallback: _logoutCallback,
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

  @override
  Widget build(BuildContext context) {
    _notificationsProvider = Provider.of<NotificationsViewModel>(context);

    if (_notificationsProvider.notificationSettingsUpdated) {
      _rootProvider.showDailyAtTime();
    }
    print('this is rootview');

    _rootProvider.sendAnalyticsEvent();

    switch (_authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return OnboardingView(
          auth: widget.auth,
          loginCallback: _loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (isNotEmpty(_userId)) {
          if (_rootProvider.isMentor()) {
            return _showLessonRequestView();
          } else {
            return _showConnectWithMentorView();
          }
        } else
          return _buildWaitingScreen();
        break;
      default:
        return _buildWaitingScreen();
    }
  }
}