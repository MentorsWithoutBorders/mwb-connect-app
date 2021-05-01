import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/cancel_lesson_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/send_link_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class LinkSent extends StatefulWidget {
  const LinkSent({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _LinkSentState();
}

class _LinkSentState extends State<LinkSent> {
  ConnectWithMentorViewModel _lessonRequestProvider;

  Widget _showLinkSentCard() {
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
              _showButtons()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    String linkType = 'Google Meet';
    String subfield = 'Web Development'.toLowerCase();
    String name = 'Noel Makwetu';
    String from = 'common.from'.tr();
    String organization = 'Education for All Children Kenya';
    String dayOfWeek = 'Saturday';
    String date = 'Jun 7th';
    String at = 'common.at'.tr();
    String time = '11:00 AM';
    String timeZone = 'GMT';
    String text = 'lesson_request.link_sent'.tr(args: [linkType, subfield, name, organization, dayOfWeek, date, time, timeZone]);
    String firstPart = text.substring(0, text.indexOf(linkType));
    String secondPart = text.substring(text.indexOf(linkType) + linkType.length, text.indexOf(subfield));
    String thirdPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(name));
    String fourthPart = text.substring(text.indexOf(timeZone) + timeZone.length);
    String link = "https://meet.google.com/mbc-cvoz-owv";

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.DOVE_GRAY,
                height: 1.5
              ),
              children: <TextSpan>[
                TextSpan(
                  text: firstPart + ' '
                ),
                TextSpan(
                  text: linkType
                ),
                TextSpan(
                  text: secondPart
                ),
                TextSpan(
                  text: subfield
                ),
               TextSpan(
                  text: thirdPart + ' '
                ), 
                TextSpan(
                  text: name,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: ' ' + from + ' '
                ),
                TextSpan(
                  text: organization,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: ' ' + 'common.on'.tr() + ' '
                ),
                TextSpan(
                  text: dayOfWeek + ', ' + date,
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
                ),
              ],
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
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
      ]
    );
  }

  Widget _showButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(bottom: 5.0, right: 15.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 1.0,
                primary: AppColors.MONZA,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                ),
                padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
              ), 
              child: Text('lesson_request.cancel_lesson'.tr(), style: const TextStyle(color: Colors.white)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: CancelLessonDialog(action: 'Cancel'),
                    hasInput: true,
                  ),
                );
              }
            ),
          ),
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(bottom: 5.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 1.0,
                primary: AppColors.JAPANESE_LAUREL,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                ),
                padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
              ), 
              child: Text('lesson_request.change_link'.tr(), style: const TextStyle(color: Colors.white)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: SendLinkDialog(),
                    hasInput: true,
                  ),
                );
              }
            ),
          ),
        ]
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showLinkSentCard();
  }
}