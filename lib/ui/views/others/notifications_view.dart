import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/authentication_service_old.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/notification_settings_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({Key key, this.auth})
    : super(key: key);   

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  NotificationsViewModel _notificationsViewModel;
  AnimationController _controller;
  Animation<Offset> _offset;  
  final int _animationDuration = 300;
  bool _isEnabled;
  String _time;
  String _pickedTime;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isEnabled = _storageService.notificationsEnabled;
      _time = _storageService.notificationsTime;
    });

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: _animationDuration));

    _offset = Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Widget _showNotifications() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return AnimatedContainer(
      duration: Duration(milliseconds: _animationDuration),
      margin: EdgeInsets.fromLTRB(20.0, statusBarHeight + 60.0, 20.0, 0.0),
      height: _isEnabled ? 75.0 : 55.0,
      child: Card(
        elevation: 3,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 12.0, 20.0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'notifications.label'.tr(),
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ALLPORTS
                        ),
                      ),
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: _isEnabled ? 1.0 : 0.0,
                          duration: Duration(milliseconds: _animationDuration),
                          child: Text(
                            _time,
                            style: const TextStyle(
                              fontSize: 16.0,
                              height: 1.5
                            ),
                          )
                        ),
                      )
                    ],
                  )
                ),
                onTap: () async {
                  if (Platform.isAndroid) {
                    _showTimePickerAndroid();
                  } else if (Platform.isIOS) {
                    _showTimePickerIOS();
                  }
                }                
              )
            ),
            // Android
            if (Platform.isAndroid) Switch(
              value: _storageService.notificationsEnabled,
              onChanged: (bool value){
                _updateNotificationsEnabled(value);
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
                  value: _storageService.notificationsEnabled,
                  onChanged: (bool value){
                    _updateNotificationsEnabled(value);
                  }
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  List<String> _initialTime() {
    return _time.split(':');   
  }

  Future<void> _showTimePickerAndroid() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(_initialTime()[0]), minute: int.parse(_initialTime()[1])),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      }
    );
    if (picked != null) {
      setState(() {
        _isEnabled = true;
      });
      _updateNotificationsEnabled(true);
      _setPickedTimeAndroid(picked);
      _updateNotificationsTime(_pickedTime);
    }    
  }

  void _setPickedTimeAndroid(TimeOfDay time) {
    _pickedTime = time.toString().replaceAll('TimeOfDay(', '');
    _pickedTime = _pickedTime.replaceAll(')', '');    
  }

  void _showTimePickerIOS() {
    _controller.forward();    
  }

  void _updateNotificationsEnabled(bool value) {
    if (value == false && Platform.isIOS) {
      _controller.reverse();
    }
    setState(() {
      _isEnabled = value;
    });    
    _storageService.notificationsEnabled = value;
    final NotificationSettings notificationSettings = NotificationSettings(enabled: value, time: _storageService.notificationsTime);
    _notificationsViewModel.updateNotificationSettings(notificationSettings);
  }

  void _updateNotificationsTime(String time) {
    setState(() {
      _time = time;
    });
    _storageService.notificationsTime = time;
    final NotificationSettings notificationSettings = NotificationSettings(enabled: _storageService.notificationsEnabled, time: time);
    _notificationsViewModel.updateNotificationSettings(notificationSettings);
  }  

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text('notifications.title'.tr()),
      )
    );
  }
  
  Widget _showCupertinoTimePicker() {
    return SlideTransition(
      position: _offset,
      child: Wrap(
        children: <Widget>[
          Container(
            color: Colors.white,
            width: double.infinity,
            height: 40.0,
            child: Row(
              children: <Widget>[
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 10.0),
                    child: Text(
                      'common.cancel'.tr(),
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue
                      ), 
                    ),
                  ),
                  onTap: () {
                    _controller.reverse();
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'notifications.time'.tr(),
                      style: const TextStyle(
                        fontSize: 16.0
                      ), 
                    ),
                  )
                ),
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    child: Text(
                      'notifications.done'.tr(),
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.blue
                      ), 
                    ),
                  ),
                  onTap: () {
                    _updateNotificationsEnabled(true);
                    if (_pickedTime != null) {
                      _updateNotificationsTime(_pickedTime);
                    }
                    _controller.reverse();
                  },
                )
              ],
            )
          ),
          Container(
            color: Colors.white,
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: Duration(hours: int.parse(_initialTime()[0]), minutes: int.parse(_initialTime()[1])),
              onTimerDurationChanged: (Duration picked) {
                _setPickedTimeIOS(picked);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _setPickedTimeIOS(Duration picked) {
    final List<String> timeSplit = picked.toString().split(':');
    _pickedTime = timeSplit[0].padLeft(2, '0') + ':' + timeSplit[1].padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    _notificationsViewModel = locator<NotificationsViewModel>();

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
          body: Stack(
            children: <Widget>[
              _showNotifications(),
              Align(
                alignment: Alignment.bottomCenter,
                child: _showCupertinoTimePicker()
              )
            ],
          )
        )
      ],
    );
  }  
}
