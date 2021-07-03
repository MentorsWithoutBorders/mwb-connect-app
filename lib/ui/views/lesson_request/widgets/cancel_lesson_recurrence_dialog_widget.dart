import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class CancelLessonRecurrenceDialog extends StatefulWidget {
  const CancelLessonRecurrenceDialog({Key key})
    : super(key: key);
    
  @override
  State<StatefulWidget> createState() => _CancelLessonRecurrenceDialogState();
}

class _CancelLessonRecurrenceDialogState extends State<CancelLessonRecurrenceDialog> {
  LessonRequestViewModel _lessonRequestProvider;
  bool _isCancellingLesson = false;  

  Widget _showCancelLessonRecurrenceDialog() {
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
    String title = 'Cancel lesson recurrence';
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
    Lesson nextLesson = _lessonRequestProvider.nextLesson;
    String studentPlural = plural('student', nextLesson.students.length);
    String text = 'lesson_request.cancel_lesson_recurrence_text'.tr(args: [studentPlural]);

    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.DOVE_GRAY,
          height: 1.5
        )
      )
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
          child: !_isCancellingLesson ? Text(
            'common.yes_cancel'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 70.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _cancelLessonRecurrence();
            Navigator.pop(context);
          },
        )
      ]
    );
  } 

  Future<void> _cancelLessonRecurrence() async {  
    _setIsCancellingLesson(true);
    await _lessonRequestProvider.cancelNextLesson(isSingleLesson: false);
  }
  
  void _setIsCancellingLesson(bool isCanceling) {
    setState(() {
      _isCancellingLesson = isCanceling;
    });  
  }    
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showCancelLessonRecurrenceDialog();
  }
}