import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/cancel_next_lesson_options_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/cancel_next_lesson_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class NextLesson extends StatefulWidget {
  const NextLesson({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _NextLessonState();
}

class _NextLessonState extends State<NextLesson> {
  ConnectWithMentorViewModel? _connectWithMentorProvider;
  String? _url = '';

  Widget _showNextLessonCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.only(bottom: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), 
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              _showText(),
              _showCancelButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    if (_connectWithMentorProvider?.isNextLesson == false) {
      return SizedBox.shrink();
    }    
    Lesson? nextLesson = _connectWithMentorProvider?.nextLesson;
    bool isNextLessonRecurrent = Utils.isLessonRecurrent(nextLesson?.dateTime as DateTime, nextLesson?.endRecurrenceDateTime);
    if (isNextLessonRecurrent == false) {    
      return _showSingleLessonText(nextLesson);
    } else {
      return _showRecurringLessonText(nextLesson);
    }
  }

  Widget _showSingleLessonText(Lesson? nextLesson) {
    DateTime nextLessonDateTime = nextLesson?.dateTime as DateTime;   
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');
    DateTime now = DateTime.now();
    String name = nextLesson?.mentor?.name as String;
    String fieldName = _connectWithMentorProvider?.fieldName as String;
    String article = Utils.getIndefiniteArticle(fieldName);
    String date = dateFormat.format(nextLessonDateTime);
    String time = timeFormat.format(nextLessonDateTime);
    String timeZone = now.timeZoneName;
    String urlType = Utils.getUrlType(nextLesson?.meetingUrl as String);
    String at = 'common.at'.tr();
    String text = 'connect_with_mentor.scheduled_lesson'.tr(args: [name, article, fieldName, date, time, timeZone, urlType]);
    String firstPart = text.substring(name.length, text.indexOf(fieldName));
    String secondPart = text.substring(text.indexOf(fieldName) + fieldName.length, text.indexOf(date));
    String thirdPart = text.substring(text.indexOf(timeZone) + timeZone.length);
    _url = nextLesson?.meetingUrl;

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 12.0),
          child: RichText(
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.DOVE_GRAY,
                height: 1.4
              ),
              children: <TextSpan>[
                TextSpan(
                  text: name,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: firstPart
                ),
                TextSpan(
                  text: fieldName
                ),
                TextSpan(
                  text: secondPart
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
                  text: thirdPart
                )
              ],
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 25.0),
          child: Center(
            child: InkWell(
              child: Text(
                _url as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline
                )
              ),
              onTap: () async => await _launchMeetingUrl()              
            )
          )
        )
      ]
    );
  }

  Future<void> _launchMeetingUrl() async {
    if (await canLaunchUrl(Uri.parse(_url as String))) {
      await launchUrl(Uri.parse(_url as String));
    } else {
      throw 'Could not launch $_url';
    }    
  }   

  Widget _showRecurringLessonText(Lesson? nextLesson) {
    DateTime nextLessonDateTime = nextLesson?.dateTime as DateTime;
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');
    DateTime now = DateTime.now();
    String name = nextLesson?.mentor?.name as String;
    String fieldName = _connectWithMentorProvider?.fieldName as String;
    String lessonDate = dateFormat.format(nextLessonDateTime);
    String dayOfWeek = lessonDate.substring(0, lessonDate.indexOf(','));
    String time = timeFormat.format(nextLessonDateTime);
    String timeZone = now.timeZoneName;
    String endRecurrenceDate = dateFormat.format(_connectWithMentorProvider?.getCorrectEndRecurrenceDate() as DateTime);
    endRecurrenceDate = endRecurrenceDate.substring(endRecurrenceDate.indexOf(',') + 2);
    String urlType = Utils.getUrlType(nextLesson?.meetingUrl as String);
    String at = 'common.at'.tr();
    String text = 'connect_with_mentor.scheduled_recurring_lesson'.tr(args: [name, fieldName, dayOfWeek, endRecurrenceDate, lessonDate, time, timeZone, urlType]);
    String firstPart = text.substring(name.length, text.indexOf(fieldName));
    String secondPart = text.substring(text.indexOf(fieldName) + fieldName.length, text.indexOf(lessonDate));
    String thirdPart = text.substring(text.indexOf(timeZone) + timeZone.length);
    _url = nextLesson?.meetingUrl;

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 12.0),
          child: RichText(
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.DOVE_GRAY,
                height: 1.4
              ),
              children: <TextSpan>[
                TextSpan(
                  text: name,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: firstPart
                ),
                TextSpan(
                  text: fieldName
                ),
                TextSpan(
                  text: secondPart
                ),
                TextSpan(
                  text: lessonDate,
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
                  text: thirdPart
                )
              ],
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 25.0),
          child: Center(
            child: InkWell(
              child: Text(
                _url as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline
                )
              ),
              onTap: () async => await _launchMeetingUrl()
            )
          )
        )
      ]
    );
  } 

  Widget _showCancelButton() {
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ), 
          child: Text('connect_with_mentor.cancel_lesson'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            _showCancelLessonDialog();
          }
        ),
      ),
    );
  } 

  void _showCancelLessonDialog() {
    Widget cancelLessonWidget;
    Lesson? nextLesson = _connectWithMentorProvider?.nextLesson;
    bool isNextLessonRecurrent = Utils.isLessonRecurrent(nextLesson?.dateTime as DateTime, nextLesson?.endRecurrenceDateTime);
    if (isNextLessonRecurrent == true) {
      cancelLessonWidget = CancelNextLessonOptionsDialog(context: context);
    } else {
      cancelLessonWidget = CancelNextLessonDialog();
    }
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: cancelLessonWidget
      ),
    );    
  }   

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showNextLessonCard();
  }
}