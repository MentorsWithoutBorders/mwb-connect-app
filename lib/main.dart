import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutuate_mixpanel/flutuate_mixpanel.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/locales.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/services/defaults_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/ui/views/root_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient.dart';
import 'package:mwb_connect_app/ui/widgets/loader.dart';

Future<void> main() async {
  setupLocator();

  WidgetsFlutterBinding.ensureInitialized();  
  await _signInAnonymously();
  await _initAppDirectory();

  var delegate = await _getDelegate();
  runApp(
    Phoenix(
      child: LocalizedApp(delegate, MWBConnectApp(AppConstants.mixpanelToken)),
    )
  );
}

_getDelegate() async {
  Directory directory = await getApplicationDocumentsDirectory();
  return await LocalizationDelegate.create(
      basePath: directory.path+'/i18n',
      fallbackLocale: 'en_US',
      supportedLocales: AppLocales.locales);  
}

_signInAnonymously() async {
  final BaseAuth auth = Auth();
  auth.getCurrentUser().then((user) async {
    if (user == null) {
      await auth.signInAnonymously();
    }
  });  
}

_initAppDirectory() async {
  DownloadService downloadService = locator<DownloadService>();
  await downloadService.initAppDirectory();  
}

_setDefaults() {
  DefaultsService defaultsService = locator<DefaultsService>();
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

  _MWBConnectAppState(this._mixpanelToken);

  _reloadDelegate(context) async {
    LocalizationDelegate delegate = await _getDelegate();
    LocalizedApp.of(context).delegate.shouldReload(delegate);
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
    MixpanelAPI.getInstance(_mixpanelToken).then((mixpanel) {
      _mixpanel = mixpanel;
      Map<String, String> properties = {"p1": "property1"};
      _mixpanel.track('Test Event', properties);      
    });

    _reloadDelegate(context);
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return FutureBuilder(
      future: getIt.allReady(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) { 
          _setDefaults();
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: locator<CommonViewModel>()),
              ChangeNotifierProvider.value(value: locator<GoalsViewModel>()),
              ChangeNotifierProvider.value(value: locator<StepsViewModel>()),
              ChangeNotifierProvider.value(value: locator<QuizzesViewModel>()),
              ChangeNotifierProvider.value(value: locator<NotificationsViewModel>())
            ],
            child: LocalizationProvider(
              state: LocalizationProvider.of(context).state,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                initialRoute: '/',
                title: 'MWBConnect',
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  localizationDelegate
                ],
                supportedLocales: localizationDelegate.supportedLocales,
                locale: localizationDelegate.currentLocale,                
                theme: ThemeData(),
                home: RootView(auth: Auth())
              )
            )
          );
        } else {
          return _buildWaitingScreen();
        }
      }
    );
  }
}

