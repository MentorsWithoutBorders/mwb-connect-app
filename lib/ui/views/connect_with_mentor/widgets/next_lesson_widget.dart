import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/cancel_next_lesson_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class NextLesson extends StatefulWidget {
  const NextLesson({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _NextLessonState();
}

class _NextLessonState extends State<NextLesson> {
  ConnectWithMentorViewModel _connectWithMentorProvider;

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
    Lesson nextLesson = _connectWithMentorProvider.nextLesson;
    if (!nextLesson.isRecurrent) {
      return _showSingleLessonText(nextLesson);
    } else {
      return _showRecurringLessonText(nextLesson);
    }
  }

  Widget _showSingleLessonText(Lesson nextLesson) {
    DateTime nextLessonDateTime = nextLesson.dateTime;   
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson);
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson);
    DateTime now = DateTime.now();
    String name = nextLesson.mentor.name;
    String subfield = nextLesson.subfield.name.toLowerCase();
    String date = dateFormat.format(nextLessonDateTime);
    String time = timeFormat.format(nextLessonDateTime);
    String timeZone = now.timeZoneName;
    String urlType = Utils.getUrlType(nextLesson.meetingUrl);
    String at = 'common.at'.tr();
    String text = 'connect_with_mentor.scheduled_lesson'.tr(args: [name, subfield, date, time, timeZone, urlType]);
    String firstPart = text.substring(name.length, text.indexOf(subfield));
    String secondPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(date));
    String thirdPart = text.substring(text.indexOf(timeZone) + timeZone.length);
    String link = nextLesson.meetingUrl;

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.DOVE_GRAY,
                height: 1.5
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
                  text: subfield
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
          padding: const EdgeInsets.only(bottom: 25.0),
          child: Center(
            child: Text(
              link,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
              )
            ),
          ),
        )
      ],
    );
  }

  Widget _showRecurringLessonText(Lesson nextLesson) {
    DateTime nextLessonDateTime = nextLesson.dateTime;
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson);
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson);
    DateTime now = DateTime.now();
    String name = nextLesson.mentor.name;
    String subfield = nextLesson.subfield.name.toLowerCase();
    String lessonDate = dateFormat.format(nextLessonDateTime);
    String dayOfWeek = lessonDate.substring(0, lessonDate.indexOf(','));
    String time = timeFormat.format(nextLessonDateTime);
    String timeZone = now.timeZoneName;
    String endRecurrentDate = dateFormat.format(_connectWithMentorProvider.getCorrectEndRecurrenceDate());
    endRecurrentDate = endRecurrentDate.substring(endRecurrentDate.indexOf(',') + 2);
    String urlType = Utils.getUrlType(nextLesson.meetingUrl);
    String at = 'common.at'.tr();
    String text = 'connect_with_mentor.scheduled_recurring_lesson'.tr(args: [name, subfield, dayOfWeek, endRecurrentDate, lessonDate, time, timeZone, urlType]);
    String firstPart = text.substring(name.length, text.indexOf(subfield));
    String secondPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(lessonDate));
    String thirdPart = text.substring(text.indexOf(timeZone) + timeZone.length);
    String link = nextLesson.meetingUrl;

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.DOVE_GRAY,
                height: 1.5
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
                  text: subfield
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
          padding: const EdgeInsets.only(bottom: 25.0),
          child: Center(
            child: Text(
              link,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
              )
            ),
          ),
        )
      ],
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
          child: Text('Cancel lesson', style: const TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AnimatedDialog(
                widgetInside: CancelNextLessonDialog(),
                hasInput: true,
              ),
            );
          }
        ),
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showNextLessonCard();
  }
}