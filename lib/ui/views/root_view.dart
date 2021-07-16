import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/viewmodels/root_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/ui/views/onboarding/onboarding_view.dart';
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
  const RootView({Key key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  NotificationsViewModel _notificationsProvider;
  RootViewModel _rootProvider;
  AuthStatus _authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = '';

  @override
  void dispose() {
    _rootProvider.didReceiveLocalNotificationSubject.close();
    _rootProvider.selectNotificationSubject.close();
    super.dispose();
  }  

  void _loginCallback() {
    setState(() {
      _userId = _rootProvider.getUserId();
      _authStatus = AuthStatus.LOGGED_IN;
    });
    //_setPreferences();
  }

  void _logoutCallback() {
    setState(() {
      _authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = '';
    });
  }
  
  Widget _showConnectWithMentorView() {
    return ConnectWithMentorView(
      logoutCallback: _logoutCallback,
    );
  }
  
  Widget _showLessonRequestView() {
    return LessonRequestView(
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

  void _setCurrentUser() {
    setState(() {
      _userId = _rootProvider.getUserId();
      _authStatus = _userId == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
    });
  }    

  void _setPreferences() {
    _rootProvider.setPreferences();   
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
  
  Future<bool> _init() async {
    _setCurrentUser();   
    _setPreferences();
    bool isMentor = await _rootProvider.getIsMentor();
    // _getImages();
    _setLocalNotifications();
    if (_notificationsProvider.notificationsSettingsUpdated) {
      _rootProvider.showDailyAtTime();
    }    
    return isMentor;
  }  

  @override
  Widget build(BuildContext context) {
    _rootProvider = Provider.of<RootViewModel>(context);
    _notificationsProvider = Provider.of<NotificationsViewModel>(context);

    print('this is rootview');

    _rootProvider.sendAnalyticsEvent();

    return FutureBuilder<bool>(
      future: _init(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (_authStatus) {
          case AuthStatus.NOT_DETERMINED:
            return _buildWaitingScreen();
            break;
          case AuthStatus.NOT_LOGGED_IN:
            return OnboardingView(
              loginCallback: _loginCallback
            );
          case AuthStatus.LOGGED_IN:
            if (snapshot.hasData) {
              bool isMentor = snapshot.data;
              if (isMentor) {
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
    );
  }
}