import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class CourseNotesDialog extends StatefulWidget {
  const CourseNotesDialog({Key? key, @required this.courseNotes, @required this.onUpdate})
    : super(key: key);

  final String? courseNotes;  
  final Function(String?)? onUpdate;

  @override
  State<StatefulWidget> createState() => _CourseNotesDialogState();
}

class _CourseNotesDialogState extends State<CourseNotesDialog> {
  String _courseNotes = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _courseNotes = widget.courseNotes ?? '';
  }

  Widget _showCourseNotesDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showCourseNotesInput(),
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
          'mentor_course.course_notes'.tr(),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        'mentor_course.course_notes_text'.tr(),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 11.0,
          color: AppColors.DOVE_GRAY,
          height: 1.2
        )
      ),
    );
  }

  Widget _showCourseNotesInput() {
    return Container(
      height: 120.0,
      margin: const EdgeInsets.only(bottom: 20.0),
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
          hintText: 'mentor_course.course_notes_placeholder'.tr(),
        ),
        initialValue: _courseNotes,
        onChanged: (String value) => _courseNotes = value.trim(),
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
            primary: AppColors.JAPANESE_LAUREL,
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
            await _submitCourseNotes();
            Navigator.pop(context);
          }
        ),
      ),
    );
  }

  Future<void> _submitCourseNotes() async {
    _setIsSubmitting(true);
    await widget.onUpdate!(_courseNotes);
    _showToast();
  }

  void _showToast() {
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('mentor_course.course_notes_sent'.tr()),
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
    if (_courseNotes != widget.courseNotes) {
      await _submitCourseNotes();
    }
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _unfocus();
        },
        child: _showCourseNotesDialog()
      ),
    );
  }
}