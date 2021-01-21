import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/views/others/notifications_view.dart';
import 'package:mwb_connect_app/ui/views/others/support_view.dart';
import 'package:mwb_connect_app/ui/views/others/feedback_view.dart';
import 'package:mwb_connect_app/ui/views/others/terms_view.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key key, this.auth, this.logoutCallback})
    : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;

  @override
  State<StatefulWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  LocalizationDelegate _localizationDelegate;
  LocalStorageService _storageService = locator<LocalStorageService>();
  TranslateService _translator = locator<TranslateService>();  
  AnalyticsService _analyticsService = locator<AnalyticsService>();  
  GoalsViewModel _goalProvider;  
  StepsViewModel _stepProvider;  

  _signOut() async {
    try {
      await widget.auth.signOut();
      _resetAll();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  void _resetAll() {
    _storageService.userId = null;
    _storageService.quizNumber = 1;
    _storageService.notificationsEnabled = AppConstants.notificationsEnabled;
    _storageService.notificationsTime = AppConstants.notificationsTime;
    _analyticsService.resetUser();
  }  

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;       
    _goalProvider = Provider.of<GoalsViewModel>(context);
    _stepProvider = Provider.of<StepsViewModel>(context);
    bool isMentor = _storageService.isMentor;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.CINNABAR
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 110,
                  padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
                  child: Image.asset('assets/images/logo.png')
                ),
                Text(
                  'MWB Connect',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    fontSize: 20,
                    color: Colors.white
                  )
                ),
              ],
            ),
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.account_circle),
              )
            ),
            dense: true,
            title: Text(_translator.getText('drawer.profile')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileView(isMentor: isMentor)));
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.notifications),
              )
            ),
            dense: true,
            title: Text(_translator.getText('drawer.notifications')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsView()));
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.help),
              )
            ),
            dense: true,
            title: Text(_translator.getText('drawer.support')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => SupportView()));
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.feedback),
              )
            ),
            dense: true,
            title: Text(_translator.getText('drawer.feedback')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => FeedbackView()));
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.library_books),
              )
            ),
            dense: true,
            title: Text(_translator.getText('drawer.terms')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => TermsView()));
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.power_settings_new),
              )
            ),
            title: Text(_translator.getText('drawer.logout')),
            onTap: () {
              _signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ); 
  }
}
