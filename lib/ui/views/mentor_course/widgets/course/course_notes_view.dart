import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class CourseNotesView extends StatefulWidget {
  const CourseNotesView({Key? key, @required this.courseNotes, @required this.onUpdate})
    : super(key: key);

  final String? courseNotes;  
  final Function(String?)? onUpdate;

  @override
  State<StatefulWidget> createState() => _CourseNotesViewState();
}

class _CourseNotesViewState extends State<CourseNotesView> {
  String _courseNotes = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _courseNotes = widget.courseNotes ?? '';
  }

  Widget _showCourseNotesView() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _showText(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 15.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: _showCourseNotesInput(),
            )
          ),
          _showSubmitButton()
        ]
      )
    );
  }

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      child: Text(
        'mentor_course.course_notes_text'.tr(),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 12.0,
          color: Colors.white,
          height: 1.4
        )
      ),
    );
  }  

  Widget _showCourseNotesInput() {
    return TextFormField(
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        fontSize: 13.0
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
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
    FocusScope.of(context).unfocus();
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
  
  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'common.course_notes'.tr(),
          textAlign: TextAlign.center
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },      
      child: Stack(
        children: <Widget>[
          BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: _showTitle(),
              backgroundColor: Colors.transparent,          
              elevation: 0.0,
              leading: GestureDetector(
                onTap: () async { 
                  Navigator.pop(context);
                },
                child: Platform.isIOS ? Icon(
                  Icons.arrow_back_ios_new
                ) : Icon(
                  Icons.arrow_back
                )
              )
            ),
            extendBodyBehindAppBar: true,
            body: _showCourseNotesView()
          )
        ],
      ),
    );
  }
}