import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/viewmodels/root_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/ui/views/onboarding/onboarding_view.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentor_course_view.dart';
import 'package:mwb_connect_app/ui/views/student_course/student_course_view.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/connect_with_mentor_view.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/lesson_request_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

final GetIt getIt = GetIt.instance;

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN
}

class RootView extends StatefulWidget {
  const RootView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  RootViewModel? _rootProvider;
  CommonViewModel? _commonProvider;
  GoalsViewModel? _goalsProvider;
  AuthStatus _authStatus = AuthStatus.NOT_DETERMINED;
  String? _userId = '';

  void _loginCallback() {
    setState(() {
      _userId = _rootProvider?.getUserId() as String;
      _authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _logoutCallback() {
    _commonProvider?.user = null;
    _commonProvider?.getGoalAttempts = 0;
    _goalsProvider?.setSelectedGoal(null);
    setState(() {
      _authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = '';
    });
  }

  Widget _showMentorCourseView() { 
    return MentorCourseView(
      logoutCallback: _logoutCallback,
    );
  }
  
  Widget _showStudentCourseView() {
    return StudentCourseView(
      logoutCallback: _logoutCallback
    );
  }
  
  Widget _showLessonRequestView() {
    return LessonRequestView(
      logoutCallback: _logoutCallback
    );
  }  
  
  Widget _showConnectWithMentorView() {
    return ConnectWithMentorView(
      logoutCallback: _logoutCallback
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
    _userId = _rootProvider?.getUserId();
    _authStatus = _userId == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
  }    
  
  Future<void> _init() async {
    if (_authStatus != AuthStatus.NOT_LOGGED_IN) {
      await Future.wait([
        _commonProvider!.getUserDetails(),
        _rootProvider!.getNextLesson(),
      ]).timeout(const Duration(seconds: 3600));
      _setCurrentUser();
    }
    if (_authStatus == AuthStatus.NOT_DETERMINED) {
      _authStatus = AuthStatus.NOT_LOGGED_IN;
    }
  }

  @override
  Widget build(BuildContext context) {
    _rootProvider = Provider.of<RootViewModel>(context);
    _commonProvider = Provider.of<CommonViewModel>(context);
    _goalsProvider = Provider.of<GoalsViewModel>(context);

    return FutureBuilder<void>(
      future: _init(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        bool? isNextLesson = _rootProvider?.isNextLesson;
        switch (_authStatus) {
          case AuthStatus.NOT_DETERMINED:
            return _buildWaitingScreen();
          case AuthStatus.NOT_LOGGED_IN:
            return OnboardingView(
              loginCallback: _loginCallback
            );
          case AuthStatus.LOGGED_IN:
            bool? isMentor = _commonProvider?.user?.isMentor;
            if (isMentor != null) {
              if (isMentor) {
               if (isNextLesson == true) {
                  return _showLessonRequestView();
                } else {
                  return _showMentorCourseView();
                }                
              } else {
                if (isNextLesson == true) {
                  return _showConnectWithMentorView();
                } else {
                  return _showStudentCourseView();
                }
              }
            } else
              return _buildWaitingScreen();
          default:
            return _buildWaitingScreen();
        }
      }
    );
  }
}