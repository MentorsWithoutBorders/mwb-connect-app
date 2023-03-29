import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class TaughtTodayDialog extends StatefulWidget {
  const TaughtTodayDialog({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _TaughtTodayDialogState();
}

class _TaughtTodayDialogState extends State<TaughtTodayDialog> {
  LessonRequestViewModel? _lessonRequestProvider;  
  String _lessonNote = '';
  bool _isSubmitting = false;

  Widget _showTaughtTodayDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showLessonNoteInput(),
          _showSubmitButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          'lesson_request.taught_today'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    int studentsNumber = 0;
    if (_lessonRequestProvider?.previousLesson != null) {
      if (_lessonRequestProvider?.previousLesson?.students != null) {
        studentsNumber = _lessonRequestProvider?.previousLesson?.students?.length as int;
      }
    }
    String studentPlural = plural('student', studentsNumber);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        'lesson_request.taught_today_text'.tr(args: [studentPlural]),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 12.0,
          color: AppColors.DOVE_GRAY,
          height: 1.4
        )
      ),
    );
  }

  Widget _showLessonNoteInput() {
    return Container(
      height: 120.0,
      margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 20.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.SILVER),
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: TextFormField(
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 13.0
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          isDense: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: const TextStyle(color: AppColors.SILVER),
          hintText: 'lesson_request.quick_notes_placeholder'.tr(),
        ),
        onChanged: (String value) => _lessonNote = value.trim(),
      ),
    );
  }
  
  Widget _showSubmitButton() {
   return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            backgroundColor: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(50.0, 3.0, 50.0, 3.0),
          ), 
          child: !_isSubmitting ? Text(
            'common.submit'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 50.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _submitTaughtToday();
            Navigator.pop(context);
          }
        ),
      ),
    );
  }

  Future<void> _submitTaughtToday() async {
    _setIsSubmitting(true);
    await _lessonRequestProvider?.addStudentsLessonNotes(_lessonNote);
    _showToast();
  }

  void _showToast() {
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('lesson_request.taught_today_sent'.tr()),
        action: SnackBarAction(
          label: 'common.close'.tr(), onPressed: scaffold.hideCurrentSnackBar
        ),
      ),
    );
  }   

  void _setIsSubmitting(bool isSubmitting) {
    setState(() {
      _isSubmitting = isSubmitting;
    });  
  }    
  
  void _unfocus() {
    FocusScope.of(context).unfocus();
  }
  
  Future<bool> _onWillPop() async {
    if (_lessonNote.isNotEmpty) {
      await _submitTaughtToday();
    }
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _unfocus();
        },
        child: _showTaughtTodayDialog()
      ),
    );
  }
}