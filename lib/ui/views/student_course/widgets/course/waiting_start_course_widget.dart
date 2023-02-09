import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/course/cancel_course_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class WaitingStartCourse extends StatefulWidget {
  const WaitingStartCourse({Key? key, @required this.text, @required this.currentStudentsText, @required this.onCancel})
    : super(key: key);
    
  final List<ColoredText>? text;
  final List<ColoredText>? currentStudentsText;
  final Function(String)? onCancel;

  @override
  State<StatefulWidget> createState() => _WaitingStartCourseState();
}

class _WaitingStartCourseState extends State<WaitingStartCourse> {

  Widget _showWaitingStartCourseCard() {  
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
              _showCancelButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 15.0),
          child: MulticolorText(
            coloredTexts: widget.text as List<ColoredText>
          )
        ),
        _showCurrentStudentsText()        
      ],
    );
  }

  Widget _showCurrentStudentsText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 15.0),
        child: MulticolorText(
          coloredTexts: widget.currentStudentsText as List<ColoredText>
        )
    );
  }

  Widget _showCancelButton() {
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ), 
          child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AnimatedDialog(
                widgetInside: CancelCourseDialog(
                  onCancel: widget.onCancel
                )
              )
            ); 
          }
        ),
      ),
    );
  } 

  @override
  Widget build(BuildContext context) {
    return _showWaitingStartCourseCard();
  }
}