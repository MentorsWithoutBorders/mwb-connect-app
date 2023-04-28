import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/string_extension.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/notifications_settings_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/ui/views/notifications/widgets/notifications_information_dialog.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils_datepickers.dart';

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
  
  Widget _showTrainingReminders() {
    return AnimatedContainer(
      duration: Duration(milliseconds: _animationDuration),
      height: _isTrainingRemindersEnabled == true ? 75.0 : 55.0,
      margin: const EdgeInsets.only(bottom: 5.0),
      child: Card(
        elevation: 3,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 12.0, 0.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: Text(
                        'notifications.training_reminders_label'.tr(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ALLPORTS
                        )
                      ),
                    ),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _isTrainingRemindersEnabled == true ? 1.0 : 0.0,
                        duration: Duration(milliseconds: _animationDuration),
                        child: Text(
                          _trainingRemindersTime as String,
                          style: const TextStyle(
                            fontSize: 16.0,
                            height: 1.4
                          )
                        )
                      )
                    )
                  ]
                )
              ),
              onTap: () async {
                _selectTime();
              }                
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 9.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,                
                  children: [
                    _showInformationIcon(),
                  ],
                ),
              )
            ),
            // Android
            if (Platform.isAndroid) Switch(
              value: _isTrainingRemindersEnabled as bool,
              onChanged: (bool value) async {
                _updateTrainingRemindersEnabled(value);
              },
              activeTrackColor: Colors.lightGreenAccent,
              activeColor: Colors.green,
            ),
            // iOS
            if (Platform.isIOS) Padding(
              padding: const EdgeInsets.only(top: 3.0, right: 3.0),
              child: Transform.scale( 
                scale: 0.8,
                child: CupertinoSwitch(
                  value: _isTrainingRemindersEnabled as bool,
                  onChanged: (bool value) async {
                    _updateTrainingRemindersEnabled(value);
                  }
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _showInformationIcon() {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        child: Container(
          height: 15.0,
          child: Image.asset(
            'assets/images/information_icon.png'
          )
        ),
      ),
      onTap: () {
        _showInformationDialog();
      }
    );
  }

  void _showInformationDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: NotificationsInformationDialog()
      )
    );     
  }  

  Future<void> _selectTime() async {
    final TargetPlatform platform = Theme.of(context).platform;
    Duration initialTime = Duration(hours: int.parse(_getInitialTimeSplit()[0]), minutes: int.parse(_getInitialTimeSplit()[1]));
    if (platform == TargetPlatform.iOS) {
      return UtilsDatePickers.showTimePickerIOS(context: context, initialTime: initialTime, setTime: _setSelectedTimeIOS);
    } else {
      return UtilsDatePickers.showTimePickerAndroid(context: context, initialTimeSplit: _getInitialTimeSplit(), setTime: _setSelectedTimeAndroid);
    }
  }
  
  List<String> _getInitialTimeSplit() {
    return _trainingRemindersTime!.split(':');   
  }
  
  void _setSelectedTimeIOS(Duration time) {
    final List<String> timeSplit = time.toString().split(':');
    final String selectedTime = timeSplit[0].padLeft(2, '0') + ':' + timeSplit[1].padLeft(2, '0');
    _updateTrainingRemindersTime(selectedTime);
  }  

  void _setSelectedTimeAndroid(TimeOfDay time) {
    final String selectedTime = time.toString().replaceAll('TimeOfDay(', '').replaceAll(')', '');
    _updateTrainingRemindersTime(selectedTime);
  }

  void _updateTrainingRemindersEnabled(bool value) async {
    setState(() {
      _isTrainingRemindersEnabled = value;
    });    
    _updateNotificationsSettings();
  }

  void _updateTrainingRemindersTime(String selectedTime) {  
    setState(() {
      _isTrainingRemindersEnabled = true;
      _trainingRemindersTime = selectedTime;
    });
    _updateNotificationsSettings();
  }  

  Widget _showStartCourseReminders() {
    final DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');
    String startCourseRemindersDate = dateFormat.format(_startCourseRemindersDate as DateTime);
    double screenWidth = MediaQuery.of(context).size.width;
    double heightEnabled = screenWidth <= 480.0 ? 95.0 : 75.0;
    double heightDisabled = screenWidth <= 480.0 ? 75.0 : 55.0;
    return AnimatedContainer(
      duration: Duration(milliseconds: _animationDuration),
      height: _isStartCourseRemindersEnabled == true ? heightEnabled : heightDisabled,
      child: Card(
        elevation: 3,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 12.0, 0.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'notifications.start_course_reminders_label'.tr(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ALLPORTS
                        )
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: AnimatedOpacity(
                            opacity: _isStartCourseRemindersEnabled == true ? 1.0 : 0.0,
                            duration: Duration(milliseconds: _animationDuration),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'common.after'.tr().capitalize() + ': ',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.DOVE_GRAY
                                  ),
                                ),
                                Text(
                                  startCourseRemindersDate,
                                  style: const TextStyle(
                                    fontSize: 16.0
                                  ),
                                ),
                                _showEditCalendarIcon()
                              ]
                            )
                          ),
                        )
                      )
                    ]
                  )
                ),
                onTap: () async {
                  _selectDate();
                }
              ),
            ),
            Container(
              width: 80.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Android
                  if (Platform.isAndroid) Switch(
                    value: _isStartCourseRemindersEnabled as bool,
                    onChanged: (bool value) async {
                      _updateStartCourseRemindersEnabled(value);
                    },
                    activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,
                  ),
                  // iOS
                  if (Platform.isIOS) Padding(
                    padding: const EdgeInsets.only(top: 3.0, right: 3.0),
                    child: Transform.scale( 
                      scale: 0.8,
                      child: CupertinoSwitch(
                        value: _isStartCourseRemindersEnabled as bool,
                        onChanged: (bool value) async {
                          _updateStartCourseRemindersEnabled(value);
                        }
                      )
                    ),
                  )
                ]
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _showEditCalendarIcon() {
    return Container(
      height: 20.0,
      padding: const EdgeInsets.only(left: 8.0, bottom: 3.0),
      child: Image.asset(
        'assets/images/edit_calendar_icon.png'
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final TargetPlatform platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      return UtilsDatePickers.showDatePickerIOS(context: context, initialDate: _startCourseRemindersDate, setDate: _updateStartCourseRemindersDate);
    } else {
      return UtilsDatePickers.showDatePickerAndroid(context: context, initialDate: _startCourseRemindersDate, setDate: _updateStartCourseRemindersDate);
    }
  }  
  
  void _updateStartCourseRemindersEnabled(bool value) async {
    setState(() {
      _isStartCourseRemindersEnabled = value;
    });    
    _updateNotificationsSettings();
  }

  void _updateStartCourseRemindersDate(DateTime date) {
    setState(() {
      _isStartCourseRemindersEnabled = true;
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
            _showTrainingReminders(),
            if (isMentor == true) _showStartCourseReminders()
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
