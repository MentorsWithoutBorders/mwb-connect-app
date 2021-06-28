import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/availability_start.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';

class AvailabilityStartDate extends StatefulWidget {
  const AvailabilityStartDate({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _AvailabilityStartDateState();
}

class _AvailabilityStartDateState extends State<AvailabilityStartDate> {
  ProfileViewModel _profileProvider;
  AvailabilityStart _availabilityStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_initSelectedDate);
  }  

  void _initSelectedDate(_) {
    final User user = _profileProvider.profile.user;
    setState(() {
      _availabilityStart = user.isAvailable ? AvailabilityStart.now : AvailabilityStart.later;
    });
    if (user.availableFrom == null || user.availableFrom.toLocal().isBefore(DateTime.now())) {
      _setAvailableFrom(DateTime.now());
    }
  }  

  Widget _showAvailabilityStartDate() {
    String date = _profileProvider.getAvailabilityStartDate();
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
                      key: const Key(AppKeys.currentlyAvailableRadio),
                      value: AvailabilityStart.now,
                      groupValue: _availabilityStart,
                      onChanged: (AvailabilityStart value) {
                        _setIsAvailable(value);
                      },
                    ),
                  ),
                  InkWell(
                    key: const Key(AppKeys.currentlyAvailableText),
                    child: Text('profile.currently_available'.tr()),
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
                      key: const Key(AppKeys.availableFromRadio),
                      value: AvailabilityStart.later,
                      groupValue: _availabilityStart,
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
                          key: const Key(AppKeys.availableFromText),
                          child: Text('profile.available_starting_from'.tr()),
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
                              key: const Key(AppKeys.availableFromDate),
                              style: const TextStyle(
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
      key: const Key(AppKeys.editCalendarIcon),
      height: 18.0,
      padding: const EdgeInsets.only(left: 8.0),
      child: Image.asset(
        'assets/images/edit_calendar_icon.png'
      ),
    );
  }
  
  void _setIsAvailable(AvailabilityStart value) {
    _unfocus();
    final bool isAvailable = value == AvailabilityStart.now ? true : false;
    _profileProvider.setIsAvailable(isAvailable);
    setState(() {
      _availabilityStart = value;
    });    
  }

  Future<void> _selectDate(BuildContext context) async {
    _unfocus();
    final TargetPlatform platform = Theme.of(context).platform;
    final DateTime availableFrom = _profileProvider.profile.user.availableFrom.toLocal();
    if (platform == TargetPlatform.iOS) {
      return Utils.showDatePickerIOS(context, availableFrom, _setAvailableFrom);
    } else {
      return Utils.showDatePickerAndroid(context, availableFrom, _setAvailableFrom);
    }
  }

  void _setAvailableFrom(DateTime picked) {
    _profileProvider.setAvailableFrom(picked);
  }

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 5.0, bottom: 5.0),
      child: Text(
        'profile.availability'.tr(),
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }
  
  void _unfocus() {
    _profileProvider.shouldUnfocus = true;
  }  

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showAvailabilityStartDate();
  }
}