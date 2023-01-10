import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/cancel_course_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class WaitingStudents extends StatefulWidget {
  const WaitingStudents({Key? key, @required this.mentorsCount, @required this.studentsCount, @required this.waitingStudentsNoPartnerText, @required this.waitingStudentsPartnerText, @required this.maximumStudentsText, @required this.currentStudentsText, @required this.cancelText, @required this.onCancel})
    : super(key: key); 

  final int? mentorsCount;
  final int? studentsCount;
  final List<ColoredText>? waitingStudentsNoPartnerText;
  final List<ColoredText>? waitingStudentsPartnerText;
  final List<ColoredText>? maximumStudentsText;
  final List<ColoredText>? currentStudentsText;
  final String? cancelText;
  final Function(String?)? onCancel;  

  @override
  State<StatefulWidget> createState() => _WaitingStudentsState();
}

class _WaitingStudentsState extends State<WaitingStudents> {
  Widget _showWaitingStudentsCard() {
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
              if (widget.mentorsCount == 1) _showWaitingStudentsNoPartnerText(),
              if (widget.mentorsCount! > 1) _showWaitingStudentsPartnerText(),
              _showMaximumStudentsText(),
              _showCurrentStudentsText(widget.studentsCount!),
              _showWaitingStudentsText(),
              _showCancelButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showWaitingStudentsNoPartnerText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 12.0),
      child: MulticolorText(
        coloredTexts: widget.waitingStudentsNoPartnerText as List<ColoredText>
      ),
    );
  }

  Widget _showWaitingStudentsPartnerText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 12.0),
      child: MulticolorText(
        coloredTexts: widget.waitingStudentsPartnerText as List<ColoredText>
      ),
    );
  }

  Widget _showMaximumStudentsText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 12.0),
      child: MulticolorText(
        coloredTexts: widget.maximumStudentsText as List<ColoredText>
      ),
    );
  }

  Widget _showCurrentStudentsText(int studentsCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 15.0),
      child: MulticolorText(
        coloredTexts: widget.currentStudentsText as List<ColoredText>
      ),
    );
  }

  Widget _showWaitingStudentsText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Center(
        child: Text(
          'mentor_course.waiting_students_text'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          )
        ),
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
          child: Text('common.cancel_course'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AnimatedDialog(
                widgetInside: CancelCourseDialog(
                  cancelText: widget.cancelText,
                  onCancel: widget.onCancel
                )
              )
            ); 
          }
        )
      )
    );
  }  

  @override
  Widget build(BuildContext context) {
    return _showWaitingStudentsCard();
  }
}