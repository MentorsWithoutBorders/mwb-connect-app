import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/string_extension.dart';
import 'package:mwb_connect_app/utils/lesson_recurrence_type.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class LessonRecurrence extends StatefulWidget {
  const LessonRecurrence({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _LessonRecurrenceState();
}

class _LessonRecurrenceState extends State<LessonRecurrence> {
  LessonRequestViewModel _lessonRequestProvider;
  LessonRecurrenceType _lessonRecurrenceType;
  final String _defaultLocale = Platform.localeName;
  bool _hasRecurrence = false;
  int _lessonsNumber;

  @override
  void initState() {
    super.initState();
    _setSelectedLessonsNumber(2);
    _setLessonRecurrenceType(LessonRecurrenceType.lessons);    
  }  

  Widget _showLessonRecurrence() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 5.0, 10.0),
      child: Wrap(
        children: [
          _showSetRecurrence(),
          _showRecurrenceTypes()
        ]
      )
    );
  }

  Widget _showSetRecurrence() {
    LessonRequestModel lessonRequest = _lessonRequestProvider.lessonRequest;
    DateTime lessonRequestDateTime = lessonRequest.lessonDateTime.toLocal();
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson);
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson);
    DateTime now = DateTime.now();
    String date = dateFormat.format(lessonRequestDateTime);
    date = date.substring(0, date.indexOf(','));
    String time = timeFormat.format(lessonRequestDateTime);
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String text = 'lesson_request.lesson_recurrence_text'.tr(args: [date, time, timeZone]);
    String firstPart = text.substring(0, text.indexOf(date));
    String secondPart = text.substring(text.indexOf(timeZone) + timeZone.length);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        children: [
          Row(
            children: <Widget>[
              SizedBox(
                width: 40.0,
                height: 35.0,                      
                child: Checkbox(
                  value: _hasRecurrence,
                  onChanged: (value) {
                    _setHasRecurrence();
                  },
                ),
              ),
              Expanded(
                child: InkWell(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.DOVE_GRAY,
                        height: 1.5
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: firstPart
                        ),
                        TextSpan(
                          text: date,
                          style: const TextStyle(
                            color: AppColors.TANGO
                          ) 
                        ),
                        TextSpan(
                          text: ' ' + at + ' '
                        ),
                        TextSpan(
                          text: time + ' ' + timeZone,
                          style: const TextStyle(
                            color: AppColors.TANGO
                          ) 
                        ),
                        TextSpan(
                          text: secondPart
                        ),
                      ],
                    )
                  ),
                  onTap: () {
                    _setHasRecurrence();
                  }
                ),
              )
            ]
          ),
        ],
      ),
    );
  }

  void _setHasRecurrence() {
    _unfocus();
    setState(() {
      _hasRecurrence = !_hasRecurrence;
    });
  }
  
  Widget _showRecurrenceTypes() {
    final DateFormat dateFormat = DateFormat(AppConstants.dateFormat, _defaultLocale);
    String date = dateFormat.format(DateTime.now()).capitalize();
    return IgnorePointer(
      ignoring: !_hasRecurrence,
      child: Opacity(
        opacity: _hasRecurrence ? 1.0 : 0.3,
        child: Container(
          margin: const EdgeInsets.only(top: 5.0, left: 30.0, bottom: 15.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 40.0,
                    height: 35.0,                      
                    child: Radio<LessonRecurrenceType>(
                      value: LessonRecurrenceType.lessons,
                      groupValue: _lessonRecurrenceType,
                      onChanged: (LessonRecurrenceType value) {
                        _unfocus();
                        _setLessonRecurrenceType(value);
                      },
                    ),
                  ),
                  _showLessonsNumber(),
                  InkWell(
                    child: Text(
                      'lessons',
                      style: const TextStyle(
                        fontSize: 12.0, 
                        color: AppColors.DOVE_GRAY
                      ) 
                    ),
                    onTap: () {
                      _unfocus();
                      _setLessonRecurrenceType(LessonRecurrenceType.lessons);
                    }
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 40.0,
                    height: 35.0,                      
                    child: Radio<LessonRecurrenceType>(
                      value: LessonRecurrenceType.date,
                      groupValue: _lessonRecurrenceType,
                      onChanged: (LessonRecurrenceType value) {
                        _unfocus();
                        _setLessonRecurrenceType(value);
                      },
                    ),
                  ),
                  InkWell(
                    child: Row(
                      children: [
                        Text(
                          'Until: ',
                          style: const TextStyle(
                            fontSize: 12.0, 
                            color: AppColors.DOVE_GRAY
                          )
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 12.0, 
                            fontWeight: FontWeight.bold,
                            color: AppColors.DOVE_GRAY
                          )
                        ),
                        _showEditCalendarIcon()
                      ],
                    ),
                    onTap: () {
                      _unfocus();
                      _setLessonRecurrenceType(LessonRecurrenceType.date);  
                      _selectDate(context);
                    }                        
                  )
                ],
              ) 
            ]
          ),
        ),
      ),
    );
  }

  Widget _showLessonsNumber() {
    return Container(
      width: 65.0,
      height: 30.0,
      padding: const EdgeInsets.only(right: 8.0),
      child: Dropdown(
        dropdownMenuItemList: _buildNumbers(),
        onTapped: _setLessonsOption,
        onChanged: _changeLessonsNumber,
        value: _lessonsNumber
      ),
    );
  }

  void _setLessonsOption() {
    _setLessonRecurrenceType(LessonRecurrenceType.lessons);    
  }

  void _changeLessonsNumber(int number) {
    _setSelectedLessonsNumber(number);
  }

  void _setSelectedLessonsNumber(int number) {
    setState(() {
      _lessonsNumber = number;
    });
  }     

  List<DropdownMenuItem<int>> _buildNumbers() {
    final List<DropdownMenuItem<int>> items = [];
    for (int i = 1; i <= 10; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text(i.toString()),
      ));
    }
    return items;
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
  
  void _setLessonRecurrenceType(LessonRecurrenceType value) {
    setState(() {
      _lessonRecurrenceType = value;
    });    
  }

  Future<void> _selectDate(BuildContext context) async {
    final TargetPlatform platform = Theme.of(context).platform;
    final DateTime endRecurrenceDate = DateTime.now();
    if (platform == TargetPlatform.iOS) {
      return Utils.showDatePickerIOS(context, endRecurrenceDate, _setEndRecurrenceDate);
    } else {
      return Utils.showDatePickerAndroid(context, endRecurrenceDate, _setEndRecurrenceDate);
    }
  }

  void _setEndRecurrenceDate(DateTime picked) {
    print(picked);
  }

  void _unfocus() {
    _lessonRequestProvider.shouldUnfocus = true;
  }  

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showLessonRecurrence();
  }
}