import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/notifications/widgets/training_reminders_information_dialog.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/utils/utils_datepickers.dart';

class TrainingReminders extends StatefulWidget {
  const TrainingReminders({Key? key, @required this.isEnabled, @required this.time, @required this.update})
    : super(key: key);

  final bool? isEnabled;
  final String? time;
  final Function(bool, String)? update;

  @override
  State<StatefulWidget> createState() => _TrainingRemindersState();
}

class _TrainingRemindersState extends State<TrainingReminders> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  final int _animationDuration = 300;
  bool? _isEnabled;
  String? _time;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
    _time = widget.time;
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
      height: _isEnabled == true ? 75.0 : 55.0,
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
                        opacity: _isEnabled == true ? 1.0 : 0.0,
                        duration: Duration(milliseconds: _animationDuration),
                        child: Text(
                          _time as String,
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
        widgetInside: TrainingRemindersInformation()
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
    return _time!.split(':');   
  }
  
  void _setSelectedTimeIOS(Duration time) {
    final List<String> timeSplit = time.toString().split(':');
    final String selectedTime = timeSplit[0].padLeft(2, '0') + ':' + timeSplit[1].padLeft(2, '0');
    _updateTime(selectedTime);
  }  

  void _setSelectedTimeAndroid(TimeOfDay time) {
    final String selectedTime = time.toString().replaceAll('TimeOfDay(', '').replaceAll(')', '');
    _updateTime(selectedTime);
  }

  void _updateIsEnabled(bool value) async {
    setState(() {
      _isEnabled = value;
    });
    _update();
  }

  void _updateTime(String selectedTime) {  
    setState(() {
      _isEnabled = true;
      _time = selectedTime;
    });
    _update();
  }  

  void _update() {
    widget.update!(_isEnabled as bool, _time as String);
  }

  @override
  Widget build(BuildContext context) {
    return _showTrainingReminders();
  }  
}
