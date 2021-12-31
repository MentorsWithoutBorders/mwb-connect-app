import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/string_extension.dart';
import 'package:mwb_connect_app/utils/lesson_recurrence_type.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_recurrence_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class LessonRecurrence extends StatefulWidget {
  const LessonRecurrence({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _LessonRecurrenceState();
}

class _LessonRecurrenceState extends State<LessonRecurrence> {
  LessonRequestViewModel? _lessonRequestProvider;
  final String _defaultLocale = Platform.localeName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) {
    _lessonRequestProvider?.initLessonRecurrence();
  }

  Widget _showLessonRecurrence() {
    LessonRecurrenceModel? lessonRecurrence = _lessonRequestProvider?.lessonRecurrence;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 5.0, 10.0),
      child: Wrap(
        children: [
          _showSetRecurrence(lessonRecurrence),
          _showRecurrenceTypes(lessonRecurrence)
        ]
      )
    );
  }

  Widget _showSetRecurrence(LessonRecurrenceModel? lessonRecurrence) {
    LessonRequestModel? lessonRequest = _lessonRequestProvider?.lessonRequest;
    DateTime lessonDateTime = DateTime.now();
    if (_lessonRequestProvider?.isLessonRequest == true && lessonRequest?.lessonDateTime != null) {
      lessonDateTime = lessonRequest?.lessonDateTime as DateTime;
    } else if (_lessonRequestProvider?.isNextLesson == true && lessonRecurrence?.dateTime != null) {
      lessonDateTime = lessonRecurrence?.dateTime as DateTime;
    }
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson);
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson);
    DateTime now = DateTime.now();
    String date = dateFormat.format(lessonDateTime);
    date = date.substring(0, date.indexOf(','));
    String time = timeFormat.format(lessonDateTime);
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String text = '';
    if (_lessonRequestProvider?.isLessonRequest == true) {
      text = 'lesson_request.lesson_request_recurrence_text'.tr(args: [date, time, timeZone]);
    } else if (_lessonRequestProvider?.isNextLesson == true) {
      text = 'lesson_request.next_lesson_recurrence_text'.tr(args: [date, time, timeZone]);
    }    
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
                  value: lessonRecurrence?.isRecurrent != null ? lessonRecurrence?.isRecurrent : false,
                  onChanged: (value) {
                    _setIsRecurrent();
                  },
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.DOVE_GRAY,
                      height: 1.4
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
              )
            ]
          ),
        ],
      ),
    );
  }

  void _setIsRecurrent() {
    _unfocus();
    _lessonRequestProvider?.setIsLessonRecurrent();
  }
  
  Widget _showRecurrenceTypes(LessonRecurrenceModel? lessonRecurrence) {
    final DateFormat dateFormat = DateFormat(AppConstants.dateFormat, _defaultLocale);
    String date = '';
    if (lessonRecurrence?.endRecurrenceDateTime != null) {
      date = dateFormat.format(lessonRecurrence?.endRecurrenceDateTime as DateTime).capitalize();
    }
    bool isRecurrent = lessonRecurrence?.isRecurrent != null ? lessonRecurrence?.isRecurrent as bool : false;
    return IgnorePointer(
      ignoring: !isRecurrent,
      child: Opacity(
        opacity: isRecurrent ? 1.0 : 0.3,
        child: Container(
          margin: const EdgeInsets.only(top: 5.0, left: 30.0, bottom: 5.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 40.0,
                    height: 35.0,                      
                    child: Radio<LessonRecurrenceType>(
                      value: LessonRecurrenceType.lessons,
                      groupValue: lessonRecurrence?.type,
                      onChanged: (LessonRecurrenceType? value) {
                        _unfocus();
                        _setLessonRecurrenceType(value);
                      },
                    ),
                  ),
                  _showLessonsNumber(lessonRecurrence),
                  InkWell(
                    child: Text(
                      plural('lesson', 2),
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
                      groupValue: lessonRecurrence?.type,
                      onChanged: (LessonRecurrenceType? value) {
                        _unfocus();
                        _setLessonRecurrenceType(value);
                      },
                    ),
                  ),
                  InkWell(
                    child: Row(
                      children: [
                        Text(
                          'lesson_request.lesson_recurrence_until'.tr(),
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
                      _selectDate(lessonRecurrence);
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

  Widget _showLessonsNumber(LessonRecurrenceModel? lessonRecurrence) {
    return Container(
      width: 65.0,
      height: 30.0,
      padding: const EdgeInsets.only(right: 8.0),
      child: Dropdown(
        dropdownMenuItemList: _buildNumbers(),
        onTapped: _setLessonsOption,
        onChanged: _changeLessonsNumber,
        value: lessonRecurrence?.lessonsNumber
      ),
    );
  }

  void _setLessonsOption() {
    _setLessonRecurrenceType(LessonRecurrenceType.lessons);    
  }

  void _changeLessonsNumber(int? number) {
    _setSelectedLessonsNumber(number!);
    _lessonRequestProvider?.setEndRecurrenceDate();
  }

  void _setSelectedLessonsNumber(int number) {
    _lessonRequestProvider?.setSelectedLessonsNumber(number);
    _lessonRequestProvider?.setLessonRecurrenceType(LessonRecurrenceType.lessons);
  }     

  List<DropdownMenuItem<int>> _buildNumbers() {
    final List<DropdownMenuItem<int>> items = [];
    for (int i = AppConstants.minLessonsNumberRecurrence; i <= AppConstants.maxLessonsNumberRecurrence; i++) {
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
      height: 20.0,
      padding: const EdgeInsets.only(left: 8.0, bottom: 3.0),
      child: Image.asset(
        'assets/images/edit_calendar_icon.png'
      ),
    );
  }
  
  void _setLessonRecurrenceType(LessonRecurrenceType? recurrenceType) {
    _lessonRequestProvider?.setLessonRecurrenceType(recurrenceType!);  
  }

  Future<void> _selectDate(LessonRecurrenceModel? lessonRecurrence) async {
    final TargetPlatform platform = Theme.of(context).platform;
    DateTime minRecurrenceDate = _lessonRequestProvider?.getMinRecurrenceDate() as DateTime;
    DateTime maxRecurrenceDate = _lessonRequestProvider?.getMaxRecurrenceDate() as DateTime;
    DateTime endRecurrenceDateTime = lessonRecurrence?.endRecurrenceDateTime as DateTime;
    if (platform == TargetPlatform.iOS) {
      return Utils.showDatePickerIOS(context: context, initialDate: endRecurrenceDateTime, firstDate: minRecurrenceDate, lastDate: maxRecurrenceDate, setDate: _setEndRecurrenceDate);
    } else {
      return Utils.showDatePickerAndroid(context: context, initialDate: endRecurrenceDateTime, firstDate: minRecurrenceDate, lastDate: maxRecurrenceDate, setDate: _setEndRecurrenceDate);
    }
  }

  void _setEndRecurrenceDate(DateTime? picked) {
    _lessonRequestProvider?.setEndRecurrenceDate(picked: picked);
    _lessonRequestProvider?.setLessonRecurrenceType(LessonRecurrenceType.date);
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);
    return _showLessonRecurrence();
  }
}