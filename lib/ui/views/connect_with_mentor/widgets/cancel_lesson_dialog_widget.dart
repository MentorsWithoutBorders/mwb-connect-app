import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/goals/goals_view.dart';

class CancelLessonDialog extends StatefulWidget {
  const CancelLessonDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _CancelLessonDialogState();
}

class _CancelLessonDialogState extends State<CancelLessonDialog> {

  Widget _showCancelLessonDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          'connect_with_mentor.cancel_lesson'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    String subfield = 'Web Development'.toLowerCase();
    String name = 'Edmond Pruteanu';
    String dayOfWeek = 'Saturday';
    String date = 'Jun 7th';
    String time = '11:00 AM';
    String timeZone = 'GMT';
    String at = 'common.at'.tr();
    String text = 'connect_with_mentor.cancel_lesson_text'.tr(args: [subfield, name, dayOfWeek, date, time, timeZone]);
    String firstPart = text.substring(0, text.indexOf(subfield));
    String secondPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(name));

    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
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
              text: firstPart
            ),
            TextSpan(
              text: subfield
            ),
            TextSpan(
              text: secondPart
            ),
            TextSpan(
              text: name,
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
              text: ' ?'
            ),
          ],
        )
      ),
    );
  }
  
  Widget _showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
            child: Text('common.no_abort'.tr(), style: const TextStyle(color: Colors.grey))
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          onPressed: () {
            print('Cancel lesson');
          },
          child: Text('common.yes_cancel'.tr(), style: const TextStyle(color: Colors.white))
        )
      ]
    );
  } 
  
  @override
  Widget build(BuildContext context) {
    return _showCancelLessonDialog();
  }
}