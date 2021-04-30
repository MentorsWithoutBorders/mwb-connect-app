import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';

class ScheduledLesson extends StatefulWidget {
  const ScheduledLesson({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _ScheduledLessonState();
}

class _ScheduledLessonState extends State<ScheduledLesson> {
  ConnectWithMentorViewModel _connectWithMentorProvider;

  Widget _showScheduledLessonCard() {
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
    String name = 'Edmond Pruteanu';
    String subfield = 'Web Development'.toLowerCase();
    String dayOfWeek = 'Saturday';
    String date = 'Jun 7th';
    String time = '11:00 AM';
    String timeZone = 'GMT';
    String at = 'at'.tr();
    String text = 'connect_with_mentor.scheduled_lesson'.tr(args: [name, subfield, dayOfWeek, date, time, timeZone]);
    String secondPart = text.substring(name.length, text.indexOf(subfield));
    String thirdPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(dayOfWeek));
    String fourthPart = text.substring(text.indexOf(timeZone) + timeZone.length);
    String link = "https://meet.google.com/mbc-cvoz-owv";

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
                  text: ' ' + subfield + ' '
                ),
                TextSpan(
                  text: thirdPart
                ),
                TextSpan(
                  text: dayOfWeek + ', ' + date + ' ' + at + ' ' + time + ' ' + timeZone,
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
            print('Cancel');
          }
        ),
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showScheduledLessonCard();
  }
}