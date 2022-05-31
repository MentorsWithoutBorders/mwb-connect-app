import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) {
    _lessonRequestProvider?.initLessonRecurrence();
  }  

  Widget _showLessonRecurrence() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 10.0),
      child: Wrap(
        children: [
          _showLessonsNumber(),
          _showLessonsText()
        ]
      )
    );
  }
  
  Widget _showLessonsNumber() {
    int lessonsNumber = _lessonRequestProvider?.lessonsNumber as int;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 6.0),
            child: Text(
              'lesson_request.lessons_number'.tr(),
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.DOVE_GRAY
              )
            )
          ),
          Row(
            children: <Widget>[
              Container(
                width: 65.0,
                height: 30.0,
                padding: const EdgeInsets.only(right: 8.0),
                child: Dropdown(
                  dropdownMenuItemList: _buildNumbers(),
                  onTapped: _unfocus,
                  onChanged: _changeLessonsNumber,
                  value: lessonsNumber
                ),
              )
            ]
          ),
        ],
      ),
    );
  }

  Widget _showLessonsText() {
    LessonRequestModel? lessonRequest = _lessonRequestProvider?.lessonRequest;
    DateTime lessonDateTime = DateTime.now();
    if (lessonRequest?.lessonDateTime != null) {
      lessonDateTime = lessonRequest?.lessonDateTime as DateTime;
    }    
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');
    DateTime now = DateTime.now();
    String date = dateFormat.format(lessonDateTime);
    String time = timeFormat.format(lessonDateTime);
    String timeZone = now.timeZoneName;
    String text = '';
    int lessonsNumber = _lessonRequestProvider?.lessonsNumber as int;
    if (lessonsNumber == 1) {
      text = 'lesson_request.lesson_request_single_lesson_text'.tr(args: [date, time, timeZone]);
      return _showSingleLessonText(text, date, time, timeZone);
    } else {
      String dayOfWeek = date.substring(0, date.indexOf(','));
      String startDate = date.substring(date.indexOf(',') + 2);
      DateTime endRecurrenceDateTime = lessonDateTime.add(Duration(days: (lessonsNumber - 1) * 7));
      String endDate = dateFormat.format(endRecurrenceDateTime).substring(date.indexOf(',') + 2);
      text = 'lesson_request.lesson_request_recurrence_text'.tr(args: [dayOfWeek, time, timeZone, startDate, endDate]);
      return _showLessonRecurrenceText(text, dayOfWeek, time, timeZone, startDate, endDate);
    }   
  }
  
  Widget _showSingleLessonText(String text, String date, String time, String timeZone) {
    String firstPart = text.substring(0, text.indexOf(date));
    String secondPart = text.substring(text.indexOf(timeZone) + timeZone.length);
    String at = 'common.at'.tr();
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, bottom: 6.0),
      child: InkWell(
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
        onTap: () {
          _unfocus();
        }            
      )
    );
  }

  Widget _showLessonRecurrenceText(String text, String dayOfWeek, String time, String timeZone, String startDate, String endDate) {
    String at = 'common.at'.tr();
    String from = 'common.from'.tr();
    String until = 'common.until'.tr();
    String firstPart = text.substring(0, text.indexOf(dayOfWeek));
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, bottom: 6.0),
      child: InkWell(
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
                text: dayOfWeek,
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
                text: ' ' + from + ' '
              ),
              TextSpan(
                text: startDate,
                style: const TextStyle(
                  color: AppColors.TANGO
                )
              ),
              TextSpan(
                text: ' ' + until + ' '
              ),
              TextSpan(
                text: endDate,
                style: const TextStyle(
                  color: AppColors.TANGO
                )
              ),
              TextSpan(
                text: '.'
              )
            ],
          )
        ),
        onTap: () {
          _unfocus();
        }            
      )
    );
  }  

  void _changeLessonsNumber(int? number) {
    _lessonRequestProvider?.lessonsNumber = number as int;
  }

  List<DropdownMenuItem<int>> _buildNumbers() {
    final List<DropdownMenuItem<int>> items = [];
    for (int i = 1; i <= AppConstants.maxLessonsNumberRecurrence; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text(i.toString())
      ));
    }
    return items;
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