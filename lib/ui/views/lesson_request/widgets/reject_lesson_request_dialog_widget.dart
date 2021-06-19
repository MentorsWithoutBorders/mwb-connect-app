import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class RejectLessonRequestDialog extends StatefulWidget {
  const RejectLessonRequestDialog({Key key})
    : super(key: key);
    
  @override
  State<StatefulWidget> createState() => _RejectLessonRequestDialogState();
}

class _RejectLessonRequestDialogState extends State<RejectLessonRequestDialog> {
  LessonRequestViewModel _lessonRequestProvider;
  bool _isRejectingLessonRequest = false;  

  Widget _showRejectLessonRequestDialog() {
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
    String title = 'lesson_request.reject_lesson_request'.tr();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson);
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson);
    DateTime now = DateTime.now();
    LessonRequestModel lessonRequest = _lessonRequestProvider.lessonRequest;
    String name = lessonRequest.student.name;
    String organization = lessonRequest.student.organization.name;
    String subfield = lessonRequest.subfield.name.toLowerCase();
    String date = dateFormat.format(lessonRequest.lessonDateTime);
    String time = timeFormat.format(lessonRequest.lessonDateTime);
    String timeZone = now.timeZoneName;
    String from = 'common.from'.tr();
    String at = 'common.at'.tr();
    String text = 'lesson_request.reject_lesson_request_text'.tr(args: [subfield, name, organization, date, time, timeZone]);
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
          child: !_isRejectingLessonRequest ? Text(
            'common.yes_reject'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 70.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _rejectLessonRequest();
            Navigator.pop(context);
          },
        )
      ]
    );
  } 

  Future<void> _rejectLessonRequest() async {  
    _setIsRejectingLessonRequest(true);
    await _lessonRequestProvider.rejectLessonRequest();
  }
  
  void _setIsRejectingLessonRequest(bool isRejecting) {
    setState(() {
      _isRejectingLessonRequest = isRejecting;
    });  
  }    
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showRejectLessonRequestDialog();
  }
}