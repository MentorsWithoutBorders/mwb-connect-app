import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/views/others/notifications_view.dart';
import 'package:mwb_connect_app/ui/views/others/support_view.dart';
import 'package:mwb_connect_app/ui/views/others/feedback_view.dart';
import 'package:mwb_connect_app/ui/views/others/terms_view.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key key, this.auth, this.logoutCallback})
    : super(key: key);   

  final BaseAuth auth;
  final VoidCallback logoutCallback;

  @override
  State<StatefulWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();  

  Future<void> _signOut() async {
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
    final bool isMentor = _storageService.isMentor;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.CINNABAR
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 110,
                  padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
                  child: Image.asset('assets/images/logo.png')
                ),
                const Text(
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
            leading: const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.account_circle),
              )
            ),
            dense: true,
            title: Text('drawer.profile'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute<ProfileView>(builder: (_) => ProfileView(isMentor: isMentor)));
            },
          ),
          ListTile(
            leading: const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.notifications),
              )
            ),
            dense: true,
            title: Text('drawer.notifications'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute<NotificationsView>(builder: (_) => NotificationsView()));
            },
          ),
          ListTile(
            leading: const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.help),
              )
            ),
            dense: true,
            title: Text('drawer.support'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute<SupportView>(builder: (_) => SupportView()));
            },
          ),
          ListTile(
            leading: const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.feedback),
              )
            ),
            dense: true,
            title: Text('drawer.feedback'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute<FeedbackView>(builder: (_) => FeedbackView()));
            },
          ),
          ListTile(
            leading: const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.library_books),
              )
            ),
            dense: true,
            title: Text('drawer.terms'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute<TermsView>(builder: (_) => TermsView()));
            },
          ),
          ListTile(
            leading: const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.power_settings_new),
              )
            ),
            title: Text('drawer.logout'.tr()),
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
