import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutuate_mixpanel/flutuate_mixpanel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/services/defaults_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/root_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/login_signup_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/ui/views/root_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

Future<void> main() async {
  setupLocator();

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await _signInFirebaseAnonymously();
  await _initAppDirectory();

  Directory directory = await getApplicationDocumentsDirectory();
  runApp(
    Phoenix(
      child: EasyLocalization(
        supportedLocales: [Locale('en', 'US')],
        path: directory.path+'/i18n',
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

class _MWBConnectAppState extends State<MWBConnectApp> {
  MixpanelAPI _mixpanel;
  String _mixpanelToken;
  //DownloadService _downloadService = locator<DownloadService>();  

  _MWBConnectAppState(this._mixpanelToken);

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
      final Map<String, String> properties = {'p1': 'property1'};
      _mixpanel.track('Test Event', properties);      
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
              ChangeNotifierProvider<ProfileViewModel>.value(value: locator<ProfileViewModel>()),
              ChangeNotifierProvider<ConnectWithMentorViewModel>.value(value: locator<ConnectWithMentorViewModel>()),
              ChangeNotifierProvider<LessonRequestViewModel>.value(value: locator<LessonRequestViewModel>()),
              ChangeNotifierProvider<GoalsViewModel>.value(value: locator<GoalsViewModel>()),
              ChangeNotifierProvider<StepsViewModel>.value(value: locator<StepsViewModel>()),
              ChangeNotifierProvider<QuizzesViewModel>.value(value: locator<QuizzesViewModel>()),
              ChangeNotifierProvider<NotificationsViewModel>.value(value: locator<NotificationsViewModel>())
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: '/',
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

