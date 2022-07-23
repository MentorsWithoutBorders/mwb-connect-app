import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class CancelNextLessonDialog extends StatefulWidget {
  const CancelNextLessonDialog({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _CancelNextLessonDialogState();
}

class _CancelNextLessonDialogState extends State<CancelNextLessonDialog> {
  ConnectWithMentorViewModel? _connectWithMentorProvider;
  String? _reasonText;
  bool _isCancelingNextLesson = false;

  Widget _showCancelNextLessonDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showReasonInput(),
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
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          )
        )
      )
    );
  }

  Widget _showText() {
    if (_connectWithMentorProvider?.isNextLesson == false) {
      return SizedBox.shrink();
    }    
    Lesson? nextLesson = _connectWithMentorProvider?.nextLesson;
    DateTime nextLessonDateTime = nextLesson?.dateTime as DateTime;  
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');
    DateTime now = DateTime.now();
    String name = nextLesson?.mentor?.name as String;
    String fieldName = _connectWithMentorProvider?.fieldName as String;
    String date = dateFormat.format(nextLessonDateTime);
    String time = timeFormat.format(nextLessonDateTime);
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String text = 'connect_with_mentor.cancel_lesson_text'.tr(args: [fieldName, name, date, time, timeZone]);
    String firstPart = text.substring(0, text.indexOf(fieldName));
    String secondPart = text.substring(text.indexOf(fieldName) + fieldName.length, text.indexOf(name));

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
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
              text: fieldName
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
              text: '?'
            ),
          ],
        )
      ),
    );
  }

  Widget _showReasonInput() {
    return Container(
      height: 80.0,
      margin: const EdgeInsets.only(bottom: 15.0),        
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.SILVER)
      ),
      child: TextFormField(
        maxLines: null,
        textInputAction: TextInputAction.go,
        style: const TextStyle(
          fontSize: 12.0
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),          
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: const TextStyle(color: AppColors.SILVER),
          hintText: 'lesson_request.cancel_lesson_reason_placeholder'.tr(),
        ),
        onChanged: (String? value) => _reasonText = value?.trim(),
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
          child: !_isCancelingNextLesson ? Text(
            'common.yes_cancel'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 70.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _cancelNextLesson();
            Navigator.pop(context);
          },
        )
      ]
    );
  }
  
  Future<void> _cancelNextLesson() async {  
    _setIsCancelingNextLesson(true);
    _connectWithMentorProvider?.nextLesson?.reasonCanceled = _reasonText;
    await _connectWithMentorProvider?.cancelNextLesson(isSingleLesson: true);
  }
  
  void _setIsCancelingNextLesson(bool isCanceling) {
    setState(() {
      _isCancelingNextLesson = isCanceling;
    });  
  }    
  
  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showCancelNextLessonDialog();
  }
}