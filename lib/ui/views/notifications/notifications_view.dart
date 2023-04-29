import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/notifications_settings_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/ui/views/notifications/widgets/start_course_reminders_widget.dart';
import 'package:mwb_connect_app/ui/views/notifications/widgets/training_reminders_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
  NotificationsViewModel? _notificationsProvider;
  CommonViewModel? _commonProvider;
  AnimationController? _animationController;
  final int _animationDuration = 300;
  bool? _isTrainingRemindersEnabled;
  String? _trainingRemindersTime;
  bool? _isStartCourseRemindersEnabled;
  DateTime? _startCourseRemindersDate;
  bool _areSettingsRetrieved = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: _animationDuration));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _updateTrainingReminders(bool? isEnabled, String? time) {
    setState(() {
      _isTrainingRemindersEnabled = isEnabled;
      _trainingRemindersTime = time;
    });
    _updateNotificationsSettings();
  }

  void _updateStartCourseReminders(bool? isEnabled, DateTime? date) {
    setState(() {
      _isStartCourseRemindersEnabled = isEnabled;
      _startCourseRemindersDate = date;
    });
    _updateNotificationsSettings();
  }

  Future<void> _updateNotificationsSettings() async {
    final NotificationsSettings notificationsSettings = NotificationsSettings(
      trainingRemindersEnabled: _isTrainingRemindersEnabled,
      trainingRemindersTime: _trainingRemindersTime,
      startCourseRemindersEnabled: _isStartCourseRemindersEnabled, 
      startCourseRemindersDate: _startCourseRemindersDate
    );
    await _notificationsProvider?.updateNotificationsSettings(notificationsSettings);
  }

  Future<void> _getNotificationSettings() async {
    if (!_areSettingsRetrieved) {
      await _notificationsProvider?.getNotificationsSettings();
      _setNotificationSettings();
      _areSettingsRetrieved = true;
    }
  }

  void _setNotificationSettings() {
    NotificationsSettings? notificationsSettings = _notificationsProvider?.notificationsSettings;
    bool trainingRemindersEnabled = AppConstants.trainingRemindersEnabled;
    String trainingRemindersTime = AppConstants.trainingRemindersTime;
    bool startCourseRemindersEnabled = AppConstants.startCourseRemindersEnabled;
    DateTime startCourseRemindersDate = DateTime.now();
    if (notificationsSettings?.trainingRemindersEnabled != null) {
      trainingRemindersEnabled = notificationsSettings?.trainingRemindersEnabled as bool;
    }
    if (notificationsSettings?.trainingRemindersTime != null) {
      trainingRemindersTime = notificationsSettings?.trainingRemindersTime as String;
    }
    if (notificationsSettings?.startCourseRemindersEnabled != null) {
      startCourseRemindersEnabled = notificationsSettings?.startCourseRemindersEnabled as bool;
    }
    if (notificationsSettings?.startCourseRemindersDate != null) {
      startCourseRemindersDate = notificationsSettings?.startCourseRemindersDate as DateTime;
    }     
    setState(() {
      _isTrainingRemindersEnabled = trainingRemindersEnabled;
      _trainingRemindersTime = trainingRemindersTime;
      _isStartCourseRemindersEnabled = startCourseRemindersEnabled;
      _startCourseRemindersDate = startCourseRemindersDate;
    });    
  }
  
  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'notifications.title'.tr(),
          textAlign: TextAlign.center
        )
      )
    );
  }  

  Widget _showContent() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bool? isMentor = _commonProvider!.getIsMentor();
    if (_areSettingsRetrieved) {
      return Container(
        padding: EdgeInsets.fromLTRB(20.0, statusBarHeight + 65.0, 20.0, 0.0),
        child: Wrap(
          children: [
            TrainingReminders(
              isEnabled: _isTrainingRemindersEnabled, 
              time: _trainingRemindersTime, 
              update: _updateTrainingReminders
            ),
            if (isMentor == true) StartCourseReminders(
              isEnabled: _isStartCourseRemindersEnabled, 
              date: _startCourseRemindersDate, 
              update: _updateStartCourseReminders
            )
          ],
        ),
      );
    } else {
      return const Loader();
    }
  }

  @override
  Widget build(BuildContext context) {
    _notificationsProvider = locator<NotificationsViewModel>();
    _commonProvider = locator<CommonViewModel>();

    return FutureBuilder<void>(
      future: _getNotificationSettings(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Stack(
          children: <Widget>[
            BackgroundGradient(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: _showTitle(),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(null),
                )
              ),
              extendBodyBehindAppBar: true,
              body: _showContent()
            )
          ],
        );
      }
    );
  }  
}
