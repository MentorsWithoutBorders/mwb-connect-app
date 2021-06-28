import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/reject_lesson_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/accept_lesson_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class LessonRequest extends StatefulWidget {
  const LessonRequest({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _LessonRequestState();
}

class _LessonRequestState extends State<LessonRequest> {
  LessonRequestViewModel _lessonRequestProvider;

  Widget _showLessonRequestCard() {
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
    LessonRequestModel lessonRequest = _lessonRequestProvider.lessonRequest;
    DateTime lessonRequestDateTime = lessonRequest.lessonDateTime.toLocal();
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson);
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson);
    DateTime now = DateTime.now();
    String name = lessonRequest.student.name;
    String organization = lessonRequest.student.organization.name;
    String subfield = lessonRequest.subfield.name.toLowerCase();
    String date = dateFormat.format(lessonRequestDateTime);
    String time = timeFormat.format(lessonRequestDateTime);
    String timeZone = now.timeZoneName;
    String from = 'common.from'.tr();
    String at = 'common.at'.tr();
    String text = 'lesson_request.lesson_request_text'.tr(args: [name, organization, subfield, date, time, timeZone]);
    String firstPart = text.substring(text.indexOf(organization) + organization.length, text.indexOf(subfield));
    String secondPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(date));

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
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
                  text: '.'
                ),
              ],
            )
          ),
        )
      ],
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
              child: Text('common.reject'.tr(), style: const TextStyle(color: Colors.white)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: RejectLessonRequestDialog(),
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
              child: Text('common.accept'.tr(), style: const TextStyle(color: Colors.white)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: AcceptLessonRequestDialog(),
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
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showLessonRequestCard();
  }
}