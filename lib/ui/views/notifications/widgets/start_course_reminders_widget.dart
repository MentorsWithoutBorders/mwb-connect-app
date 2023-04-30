import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/string_extension.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils_datepickers.dart';

class StartCourseReminders extends StatefulWidget {
  const StartCourseReminders({Key? key, @required this.isEnabled, @required this.date, @required this.update})
    : super(key: key);
    
  final bool? isEnabled;
  final DateTime? date;
  final Function(bool, DateTime)? update;    

  @override
  State<StatefulWidget> createState() => _StartCourseRemindersState();
}

class _StartCourseRemindersState extends State<StartCourseReminders> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  final int _animationDuration = 300;
  bool? _isEnabled;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
    _date = widget.date;
    if (_date != null) {
      DateTime today = DateTime.now();
      if (_date!.isBefore(today)) {
        _date = today;
      }
    }
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: _animationDuration));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Widget _showStartCourseReminders() {
    final DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');
    String startCourseRemindersDate = dateFormat.format(_date as DateTime);
    double screenWidth = MediaQuery.of(context).size.width;
    double heightEnabled = screenWidth <= 480.0 ? 95.0 : 75.0;
    double heightDisabled = screenWidth <= 480.0 ? 75.0 : 55.0;
    return AnimatedContainer(
      duration: Duration(milliseconds: _animationDuration),
      height: _isEnabled == true ? heightEnabled : heightDisabled,
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
                            opacity: _isEnabled == true ? 1.0 : 0.0,
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
                    value: _isEnabled as bool,
                    onChanged: (bool value) async {
                      _updateIsEnabled(value);
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
                        value: _isEnabled as bool,
                        onChanged: (bool value) async {
                          _updateIsEnabled(value);
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
      return UtilsDatePickers.showDatePickerIOS(context: context, initialDate: _date, setDate: _updateStartCourseRemindersDate);
    } else {
      return UtilsDatePickers.showDatePickerAndroid(context: context, initialDate: _date, setDate: _updateStartCourseRemindersDate);
    }
  }  
  
  void _updateIsEnabled(bool value) async {
    setState(() {
      _isEnabled = value;
    });    
    _update();
  }

  void _updateStartCourseRemindersDate(DateTime date) {
    setState(() {
      _isEnabled = true;
      _date = date;
    });
    _update();
  }

  void _update() {
    widget.update!(_isEnabled as bool, _date as DateTime);
  }

  @override
  Widget build(BuildContext context) {
    return _showStartCourseReminders();
  }  
}
