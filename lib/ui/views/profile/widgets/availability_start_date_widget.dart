import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';

enum Start { now, later }

class AvailabilityStartDate extends StatefulWidget {
  const AvailabilityStartDate({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _AvailabilityStartDateState();
}

class _AvailabilityStartDateState extends State<AvailabilityStartDate> {
  ProfileViewModel _profileProvider;
  Start _start;
  final DateTime _now = DateTime.now();
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {  
      _profileProvider = Provider.of<ProfileViewModel>(context);
      _initSelectedDate();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _initSelectedDate() {
    User user = _profileProvider.profile.user;
    setState(() {
      _start = user.isAvailable ? Start.now : Start.later;
    });
    if (user.availableFrom == null || user.availableFrom.isBefore(DateTime.now())) {
      _setAvailableFrom(DateTime.now());
    }
  }  

  Widget _showAvailabilityStartDate() {
    final dateFormat = new DateFormat('MMMM dd, yyyy');
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
                    child: Radio<Start>(
                      value: Start.now,
                      groupValue: _start,
                      onChanged: (Start value) {
                        _setIsAvailable(value);
                      },
                    ),
                  ),
                  InkWell(
                    child: Text('I\'m currently available'),
                    onTap: () {
                      _setIsAvailable(Start.now);
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
                    child: Radio<Start>(
                      value: Start.later,
                      groupValue: _start,
                      onChanged: (Start value) {
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
                          child: Text('I\'m available starting from:'),
                          onTap: () {
                            _setIsAvailable(Start.later);
                          }
                        ),
                      ),
                      InkWell(
                        child: Row(
                          children: [
                            Text(
                              dateFormat.format(_profileProvider.profile.user.availableFrom),
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
                          _setIsAvailable(Start.later);  
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
      key: Key(AppKeys.editAvailabilityStartDateIcon),
      height: 18.0,
      padding: const EdgeInsets.only(left: 8.0),
      child: Image.asset(
        'assets/images/edit_calendar_icon.png'
      ),
    );
  }
  
  void _setIsAvailable(Start value) {
    bool isAvailable = value == Start.now ? true : false;
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