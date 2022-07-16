import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/views/notifications/notifications_view.dart';
import 'package:mwb_connect_app/ui/views/goals/goals_view.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/goal_steps_view.dart';
import 'package:mwb_connect_app/ui/views/others/support_request_view.dart';
import 'package:mwb_connect_app/ui/views/others/privacy_view.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key, this.logoutCallback})
    : super(key: key);   

  final VoidCallback? logoutCallback;

  @override
  State<StatefulWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final AuthService _authService = locator<AuthService>();
  LessonRequestViewModel? _lessonRequestProvider;
  ConnectWithMentorViewModel? _connectWithMentorProvider;  
  CommonViewModel? _commonProvider;  
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;

  void _logout() {
    widget.logoutCallback!();
    _authService.logout();
  }

  void _goToTraining() {
    if (_commonProvider!.getIsMentor() == true) {
      _goToGoalMentor();
    } else if (_commonProvider!.getIsMentor() == false) {
      _goToGoalStudent();
    }
  }

  void _goToGoalMentor() {
    if (_goalsProvider?.selectedGoal != null) {
      _goToGoalStepsMentor();
    } else {
      _lessonRequestProvider?.addLogEntry('goal is null in drawer_widget');
      Navigator.push(context, MaterialPageRoute<GoalsView>(builder: (_) => GoalsView())).then((value) => _goToGoalStepsMentor());
    }
  }
  
  void _goToGoalStepsMentor() {
    if (_goalsProvider?.selectedGoal != null) {
      _stepsProvider?.setShouldShowTutorialChevrons(false);
      _stepsProvider?.setIsTutorialPreviewsAnimationCompleted(false); 
      Navigator.push(context, MaterialPageRoute<GoalStepsView>(builder: (_) => GoalStepsView()));
    }
  }

  void _goToGoalStudent() {
    if (_goalsProvider?.selectedGoal == null) {
      _connectWithMentorProvider?.addLogEntry('goal is null in drawer_widget');
    }
    _goToGoalStepsStudent();
  }

  void _goToGoalStepsStudent() {
    _stepsProvider?.setShouldShowTutorialChevrons(false);
    _stepsProvider?.setIsTutorialPreviewsAnimationCompleted(false); 
    Navigator.push(context, MaterialPageRoute<GoalStepsView>(builder: (_) => GoalStepsView()));
  }

  @override
  Widget build(BuildContext context) {
    _commonProvider = Provider.of<CommonViewModel>(context);
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context); 

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
              Navigator.push(context, MaterialPageRoute<ProfileView>(builder: (_) => ProfileView(logoutCallback: widget.logoutCallback)));
            },
          ),
          ListTile(
            leading: const Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: IconTheme(
                data: IconThemeData(
                  color: AppColors.SILVER
                ),
                child: Icon(Icons.model_training),
              )
            ),
            dense: true,
            title: Text('drawer.training'.tr()),
            onTap: () {
              Navigator.pop(context);
              _goToTraining();
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
                child: Icon(Icons.library_books),
              )
            ),
            dense: true,
            title: Text('drawer.privacy'.tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute<PrivacyView>(builder: (_) => PrivacyView()));
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
              _logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ); 
  }
}
