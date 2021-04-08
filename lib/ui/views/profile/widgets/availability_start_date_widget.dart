import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/string_extension.dart';
import 'package:mwb_connect_app/utils/availability_start.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';

class AvailabilityStartDate extends StatefulWidget {
  const AvailabilityStartDate({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _AvailabilityStartDateState();
}

class _AvailabilityStartDateState extends State<AvailabilityStartDate> {
  ProfileViewModel _profileProvider;
  AvailabilityStart _start;
  final DateTime _now = DateTime.now();
  final String defaultLocale = Platform.localeName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_initSelectedDate);
  }  

  void _initSelectedDate(_) {
    User user = _profileProvider.profile.user;
    setState(() {
      _start = user.isAvailable ? AvailabilityStart.now : AvailabilityStart.later;
    });
    if (user.availableFrom == null || user.availableFrom.isBefore(DateTime.now())) {
      _setAvailableFrom(DateTime.now());
    }
  }  

  Widget _showAvailabilityStartDate() {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy', defaultLocale);
    String date = DateTime.now().toString().capitalize();
    if (_profileProvider.profile.user.availableFrom != null) {
      date = dateFormat.format(_profileProvider.profile.user.availableFrom).capitalize();
    }
    return Wrap(
      children: [
        _showTitle(),
        Container(
          margin: const EdgeInsets.only(top: 5.0, bottom: 15.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 40.0,
                    height: 35.0,                      
                    child: Radio<AvailabilityStart>(
                      key: Key(AppKeys.currentlyAvailableRadio),
                      value: AvailabilityStart.now,
                      groupValue: _start,
                      onChanged: (AvailabilityStart value) {
                        _setIsAvailable(value);
                      },
                    ),
                  ),
                  InkWell(
                    key: Key(AppKeys.currentlyAvailableText),
                    child: Text('I\'m currently available'),
                    onTap: () {
                      _setIsAvailable(AvailabilityStart.now);
                    }
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 40.0,
                    height: 35.0,                      
                    child: Radio<AvailabilityStart>(
                      key: Key(AppKeys.availableFromRadio),
                      value: AvailabilityStart.later,
                      groupValue: _start,
                      onChanged: (AvailabilityStart value) {
                        _setIsAvailable(value);
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: InkWell(
                          key: Key(AppKeys.availableFromText),
                          child: Text('I\'m available starting from:'),
                          onTap: () {
                            _setIsAvailable(AvailabilityStart.later);
                          }
                        ),
                      ),
                      InkWell(
                        child: Row(
                          children: [
                            Text(
                              date,
                              key: Key(AppKeys.availableFromDate),
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.bold,
                                color: AppColors.DOVE_GRAY
                              ),
                            ),
                            _showEditCalendarIcon()
                          ],
                        ),
                        onTap: () {
                          _setIsAvailable(AvailabilityStart.later);  
                          _selectDate(context);
                        }                        
                      )
                    ],
                  )
                ],
              ), 
            ]
          ),
        )
      ]
    );
  }

  Widget _showEditCalendarIcon() {
    return Container(
      key: Key(AppKeys.editCalendarIcon),
      height: 18.0,
      padding: const EdgeInsets.only(left: 8.0),
      child: Image.asset(
        'assets/images/edit_calendar_icon.png'
      ),
    );
  }
  
  void _setIsAvailable(AvailabilityStart value) {
    bool isAvailable = value == AvailabilityStart.now ? true : false;
    _profileProvider.setIsAvailable(isAvailable);
    setState(() {
      _start = value;
    });    
  }

  void _selectDate(BuildContext context) async {
    final TargetPlatform platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      return _showDatePickerIOS(context);
    } else {
      return _showDatePickerAndroid(context);
    }
  }

  void _showDatePickerAndroid(BuildContext context) async {
    DateTime availableFrom = _profileProvider.profile.user.availableFrom;
    final DateTime picked = await showDatePicker(
      context: context,
      locale: Locale(defaultLocale.split('_')[0], defaultLocale.split('_')[1]),
      initialDate: availableFrom,
      firstDate: _now,
      lastDate: DateTime(_now.year + 4),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },      
    );
    if (picked != null && picked != availableFrom) {
      _setAvailableFrom(picked);
    }
  }

  void _setAvailableFrom(DateTime picked) {
    _profileProvider.setAvailableFrom(picked);
  }

  void _showDatePickerIOS(BuildContext context) {
    DateTime availableFrom = _profileProvider.profile.user.availableFrom;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Wrap(
          children: [
            Container(
              color: AppColors.WILD_SAND,
              height: 40.0,
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  child: Text(
                    'Done',
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue
                    ), 
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              )
            ),
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              color: Colors.white,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (picked) {
                  if (picked != null && picked != availableFrom) {
                    _setAvailableFrom(picked);
                  }
                },
                initialDateTime: availableFrom,
                minimumYear: _now.year,
                maximumYear: _now.year + 4,
              ),
            ),
          ],
        );
      }
    );
  }    

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 5.0, bottom: 5.0),
      child: const Text(
        'Availability',
        style: TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showAvailabilityStartDate();
  }
}