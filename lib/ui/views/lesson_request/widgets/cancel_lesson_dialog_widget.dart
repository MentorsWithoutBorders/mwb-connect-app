import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/goals/goals_view.dart';

class CancelLessonDialog extends StatefulWidget {
  const CancelLessonDialog({Key key, this.action})
    : super(key: key);
    
  final String action;

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
          'lesson_request.cancel_lesson'.tr(args: [widget.action]),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    String action = widget.action.toLowerCase();
    String subfield = 'Web Development'.toLowerCase();
    String name = 'Noel Makwetu';
    String from = 'common.from'.tr();
    String organization = 'Education for All Children Kenya';
    String dayOfWeek = 'Saturday';
    String date = 'Jun 7th';
    String time = '11:00 AM';
    String at = 'common.at'.tr();
    String timeZone = 'GMT';
    String text = 'lesson_request.cancel_lesson_text'.tr(args: [action, subfield, name, organization, dayOfWeek, date, time, timeZone]);
    String firstPart = text.substring(0, text.indexOf(subfield));
    String secondPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(name));
    String thirdPart = text.substring(text.indexOf(timeZone) + timeZone.length, text.length);

    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
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
              text: thirdPart
            ),
          ],
        )
      ),
    );
  }
  
  Widget _showButtons() {
    String actionText = widget.action == 'Cancel' ? 'common.yes_cancel'.tr() : 'common.yes_reject'.tr();
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
          child: Text(actionText, style: const TextStyle(color: Colors.white))
        )
      ]
    );
  } 
  
  @override
  Widget build(BuildContext context) {
    return _showCancelLessonDialog();
  }
}