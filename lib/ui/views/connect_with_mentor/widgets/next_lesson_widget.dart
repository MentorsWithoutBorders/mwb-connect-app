import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
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
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson);
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson);
    DateTime now = DateTime.now();
    Lesson nextLesson = _connectWithMentorProvider.nextLesson;
    String name = nextLesson.mentor.name;
    String subfield = nextLesson.subfield.name.toLowerCase();
    String date = dateFormat.format(nextLesson.dateTime);
    String time = timeFormat.format(nextLesson.dateTime);
    String timeZone = now.timeZoneName;
    String urlType = Utils.getUrlType(nextLesson.meetingUrl);
    String at = 'common.at'.tr();
    String text = 'connect_with_mentor.scheduled_lesson'.tr(args: [name, subfield, date, time, timeZone, urlType]);
    String secondPart = text.substring(name.length, text.indexOf(subfield));
    String thirdPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(date));
    String fourthPart = text.substring(text.indexOf(timeZone) + timeZone.length);
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
                  text: secondPart
                ),
                TextSpan(
                  text: subfield
                ),
                TextSpan(
                  text: thirdPart
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
                  text: fourthPart
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
          child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.white)),
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