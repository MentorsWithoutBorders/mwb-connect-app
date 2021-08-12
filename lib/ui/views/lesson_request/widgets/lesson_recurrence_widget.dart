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
import 'package:mwb_connect_app/core/models/lesson_model.dart';
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
  final String _defaultLocale = Platform.localeName;
  int _lessonsNumber;
  LessonRecurrenceType _lessonRecurrenceType;

  @override
  void didChangeDependencies() {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.didChangeDependencies();
  }
  
  void _afterLayout(_) {
    _lessonRequestProvider.initLessonRecurrence();
    if (_lessonRequestProvider.isNextLesson && _lessonRequestProvider.nextLesson.isRecurrent) {
      _setLessonRecurrenceType(_lessonRequestProvider.getLessonRecurrenceType());
      _setSelectedLessonsNumber(_lessonRequestProvider.calculateLessonsNumber(_lessonRequestProvider.nextLesson.endRecurrenceDateTime));
    } else {
      _setLessonRecurrenceType(LessonRecurrenceType.lessons);
      _setSelectedLessonsNumber(AppConstants.minLessonsNumberRecurrence);
      _setEndRecurrenceDate(null);
    }
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
    Lesson nextLesson = _lessonRequestProvider.nextLesson;
    DateTime lessonDateTime = DateTime.now();
    if (_lessonRequestProvider.isLessonRequest) {
      lessonDateTime = lessonRequest.lessonDateTime;
    } else if (_lessonRequestProvider.isNextLesson) {
      lessonDateTime = nextLesson.dateTime;
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
    if (_lessonRequestProvider.isLessonRequest) {
      text = 'lesson_request.lesson_request_recurrence_text'.tr(args: [date, time, timeZone]);
    } else if (_lessonRequestProvider.isNextLesson) {
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
                  value: _lessonRequestProvider.nextLesson.isRecurrent != null ? _lessonRequestProvider.nextLesson.isRecurrent : false,
                  onChanged: (value) {
                    _setIsRecurrent();
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
                    _setIsRecurrent();
                  }
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
    _lessonRequestProvider.setIsLessonRecurrent();
  }
  
  Widget _showRecurrenceTypes() {
    final DateFormat dateFormat = DateFormat(AppConstants.dateFormat, _defaultLocale);
    String date = '';
    if (_lessonRequestProvider.nextLesson.endRecurrenceDateTime != null) {
      date = dateFormat.format(_lessonRequestProvider.nextLesson.endRecurrenceDateTime).capitalize();
    }
    bool isRecurrent = _lessonRequestProvider.nextLesson.isRecurrent != null ? _lessonRequestProvider.nextLesson.isRecurrent : false;
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
                      _selectDate();
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
    _setEndRecurrenceDate(null);
  }

  void _setSelectedLessonsNumber(int number) {
    if (mounted) {
      setState(() {
        _lessonsNumber = number;
      });
    }
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
  
  void _setLessonRecurrenceType(LessonRecurrenceType recurrenceType) {
    if (mounted) {
      setState(() {
        _lessonRecurrenceType = recurrenceType;
      });
    }
    _lessonRequestProvider.setLessonRecurrenceType(recurrenceType);  
  }

  Future<void> _selectDate() async {
    final TargetPlatform platform = Theme.of(context).platform;
    DateTime minRecurrenceDate = _lessonRequestProvider.getMinRecurrenceDate();
    DateTime maxRecurrenceDate = _lessonRequestProvider.getMaxRecurrenceDate();
    DateTime endRecurrenceDateTime = _lessonRequestProvider.nextLesson.endRecurrenceDateTime;
    if (platform == TargetPlatform.iOS) {
      return Utils.showDatePickerIOS(context: context, initialDate: endRecurrenceDateTime, firstDate: minRecurrenceDate, lastDate: maxRecurrenceDate, setDate: _setEndRecurrenceDate);
    } else {
      return Utils.showDatePickerAndroid(context: context, initialDate: endRecurrenceDateTime, firstDate: minRecurrenceDate, lastDate: maxRecurrenceDate, setDate: _setEndRecurrenceDate);
    }
  }

  void _setEndRecurrenceDate(DateTime picked) {
    _lessonRequestProvider.setEndRecurrenceDate(picked: picked, lessonsNumber: _lessonsNumber);
    if (picked != null) {
      _setSelectedLessonsNumber(_lessonRequestProvider.calculateLessonsNumber(_lessonRequestProvider.nextLesson.endRecurrenceDateTime));
    }
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return _showLessonRecurrence();
  }
}