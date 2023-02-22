import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutuate_mixpanel/flutuate_mixpanel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/services/defaults_service.dart';
import 'package:mwb_connect_app/core/services/push_notifications_service.dart';
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/root_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/login_signup_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/forgot_password_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentor_course_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentors_waiting_requests_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course/student_course_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course/available_courses_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/in_app_messages_view_model.dart';
import 'package:mwb_connect_app/ui/views/root_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

Future<void> main() async {
  setupLocator();  

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await _signInFirebaseAnonymously();

  runApp(
    Phoenix(
      child: EasyLocalization(
        supportedLocales: [Locale('en', 'US')],
        path: 'assets/i18n',
        fallbackLocale: const Locale('en', 'US'),
        child: MWBConnectApp(AppConstants.mixpanelToken)
      ),
    )
  );
}

Future<void> _signInFirebaseAnonymously() async {
  await FirebaseAuth.instance.signInAnonymously();
}

Future<void> _initAppDirectory() async {
  final DownloadService downloadService = locator<DownloadService>();
  await downloadService.initAppDirectory();  
}

void _setDefaults() {
  final DefaultsService defaultsService = locator<DefaultsService>();
  defaultsService.setDefaults();    
}

class MWBConnectApp extends StatefulWidget {
  final String _mixpanelToken;

  MWBConnectApp(this._mixpanelToken);

  @override
  _MWBConnectAppState createState() => _MWBConnectAppState(_mixpanelToken);
}

class _MWBConnectAppState extends State<MWBConnectApp> with WidgetsBindingObserver {
  MixpanelAPI? _mixpanel;
  String _mixpanelToken;

  _MWBConnectAppState(this._mixpanelToken);

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 500), () async {
        // await _initPushNotifications();
      });
    }); 
  }

  Future<void> _initPushNotifications() async {
    final PushNotificationsService pushNotificationsService = locator<PushNotificationsService>();
    await pushNotificationsService.init();
  }     

  Widget _buildWaitingScreen() {
    return MaterialApp(
      home: Stack(
        children: <Widget>[
          BackgroundGradient(),
          Loader()
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MixpanelAPI.getInstance(_mixpanelToken).then((MixpanelAPI mixpanel) {
      _mixpanel = mixpanel;
      // final Map<String, String> properties = {'p1': 'property1'};
      // _mixpanel.track('Test Event', properties);      
    });

    return FutureBuilder(
      future: getIt.allReady(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) { 
          _setDefaults();
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<CommonViewModel>.value(value: locator<CommonViewModel>()),
              ChangeNotifierProvider<RootViewModel>.value(value: locator<RootViewModel>()),
              ChangeNotifierProvider<LoginSignupViewModel>.value(value: locator<LoginSignupViewModel>()),
              ChangeNotifierProvider<ForgotPasswordViewModel>.value(value: locator<ForgotPasswordViewModel>()),
              ChangeNotifierProvider<ProfileViewModel>.value(value: locator<ProfileViewModel>()),
              ChangeNotifierProvider<MentorCourseViewModel>.value(value: locator<MentorCourseViewModel>()),
              ChangeNotifierProvider<StudentCourseViewModel>.value(value: locator<StudentCourseViewModel>()),
              ChangeNotifierProvider<AvailableCoursesViewModel>.value(value: locator<AvailableCoursesViewModel>()),
              ChangeNotifierProvider<MentorsWaitingRequestsViewModel>.value(value: locator<MentorsWaitingRequestsViewModel>()),
              ChangeNotifierProvider<ConnectWithMentorViewModel>.value(value: locator<ConnectWithMentorViewModel>()),
              ChangeNotifierProvider<AvailableMentorsViewModel>.value(value: locator<AvailableMentorsViewModel>()),
              ChangeNotifierProvider<LessonRequestViewModel>.value(value: locator<LessonRequestViewModel>()),
              ChangeNotifierProvider<GoalsViewModel>.value(value: locator<GoalsViewModel>()),
              ChangeNotifierProvider<StepsViewModel>.value(value: locator<StepsViewModel>()),
              ChangeNotifierProvider<QuizzesViewModel>.value(value: locator<QuizzesViewModel>()),
              ChangeNotifierProvider<NotificationsViewModel>.value(value: locator<NotificationsViewModel>()),
              ChangeNotifierProvider<InAppMessagesViewModel>.value(value: locator<InAppMessagesViewModel>())
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: NavigationService.instance.navigationKey,
              initialRoute: '/',
              routes: {
                'root':(BuildContext context) => RootView(),
              },              
              title: 'MWBConnect',
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,                
              theme: ThemeData(),
              home: RootView()
            )
          );
        } else {
          return _buildWaitingScreen();
        }
      }
    );
  }
}