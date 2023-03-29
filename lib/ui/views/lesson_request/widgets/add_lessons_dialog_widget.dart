import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/lesson_recurrence_result_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class AddLessonsDialog extends StatefulWidget {
  const AddLessonsDialog({Key? key, @required this.lesson, this.reload})
    : super(key: key);  

  final Lesson? lesson;
  final Function? reload;

  @override
  State<StatefulWidget> createState() => _AddLessonsDialogState();
}

class _AddLessonsDialogState extends State<AddLessonsDialog> {
  LessonRequestViewModel? _lessonRequestProvider;
  int _lessonsNumber = 1;
  bool _isAddingLessons = false;
  
  Widget _showAddLessonsDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showLessonsNumber(),
          _showLessonsText(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Center(
        child: Text(
          'lesson_request.add_lessons'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showLessonsNumber() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0, bottom: 6.0),
            child: Text(
              'lesson_request.lessons_to_add'.tr(),
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
                  onChanged: _changeLessonsNumber,
                  value: _lessonsNumber
                )
              )
            ]
          )
        ]
      )
    );
  }

  Widget _showLessonsText() {
    DateTime lessonDateTime = _lessonRequestProvider?.getLessonDateTimeForRecurrence(widget.lesson) as DateTime;
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');
    DateTime now = DateTime.now();
    String date = dateFormat.format(lessonDateTime);
    String time = timeFormat.format(lessonDateTime);
    String timeZone = now.timeZoneName;
    String dayOfWeek = date.substring(0, date.indexOf(','));
    DateTime endRecurrenceDateTime = lessonDateTime.add(Duration(days: _lessonsNumber * 7));
    String endDate = dateFormat.format(endRecurrenceDateTime).substring(date.indexOf(',') + 2);
    String text = 'lesson_request.lesson_request_recurrence_text'.tr(args: [dayOfWeek, time, timeZone, endDate]);
    return _showLessonRecurrenceText(text, dayOfWeek, time, timeZone, endDate);
  }

  Widget _showLessonRecurrenceText(String text, String dayOfWeek, String time, String timeZone, String endDate) {
    String at = 'common.at'.tr();
    String until = 'common.until'.tr();
    String firstPart = text.substring(0, text.indexOf(dayOfWeek));
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, bottom: 15.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13.0,
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
      )
    );
  }  

  void _changeLessonsNumber(int? number) {
    setState(() {
      _lessonsNumber = number as int;
    });
  }

  List<DropdownMenuItem<int>> _buildNumbers() {
    final List<DropdownMenuItem<int>> items = [];
    for (int i = 1; i <= AppConstants.maxLessonsNumberRecurrence; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text(i.toString()),
      ));
    }
    return items;
  }

  Widget _showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
            child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
          ),
          onTap: () {
            _closeDialog();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          child: !_isAddingLessons ? Text(
            'lesson_request.add_lessons'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 78.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _addLessons();
          }
        )
      ]
    );
  } 

  void _closeDialog() {
    Navigator.pop(context);
  }

  Future<void> _addLessons() async {
    DateTime lessonDateTime = _lessonRequestProvider?.getLessonDateTimeForRecurrence(widget.lesson) as DateTime;
    DateTime endRecurrenceDateTime = lessonDateTime.add(Duration(days: _lessonsNumber * 7));
    _setIsAddingLessons(true);
    bool? isPreviousLesson = _lessonRequestProvider?.isPreviousLesson;
    bool? isNextLesson = _lessonRequestProvider?.isNextLesson;
    int previousLessonStudentsNumber = 0;
    if (isPreviousLesson == true) {
      List<User> previousLessonStudents = _lessonRequestProvider?.previousLesson?.students as List<User>;
      previousLessonStudentsNumber = previousLessonStudents.length;
    }
    LessonRecurrenceResult lessonRecurrenceResult = await _lessonRequestProvider?.updateLessonRecurrence(widget.lesson, endRecurrenceDateTime) as LessonRecurrenceResult;
    if (isPreviousLesson == true && widget.reload != null) {
      widget.reload!();
    }    
    Navigator.pop(context);
    String lessonRecurrenceText = _lessonRequestProvider?.getLessonRecurrenceText(previousLessonStudentsNumber, lessonRecurrenceResult.studentsRemaining as int) as String;
    if (isPreviousLesson == true && isNextLesson != true && previousLessonStudentsNumber != 0 && previousLessonStudentsNumber != lessonRecurrenceResult.studentsRemaining || 
        lessonRecurrenceResult.studentsRemaining == 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedDialog(
            widgetInside: NotificationDialog(
              text: lessonRecurrenceText,
              buttonText: 'common.ok'.tr(),
              shouldReload: false
            )
          );
        }
      );  
    } else {
      _showToast();
    }
  }
  
  void _setIsAddingLessons(bool isAddingLessons) {
    setState(() {
      _isAddingLessons = isAddingLessons;
    });  
  }

  void _showToast() {
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('lesson_request.lesson_recurrence_updated'.tr()),
        action: SnackBarAction(
          label: 'common.close'.tr(), onPressed: scaffold.hideCurrentSnackBar
        ),
      ),
    );
  }      
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showAddLessonsDialog();
  }
}