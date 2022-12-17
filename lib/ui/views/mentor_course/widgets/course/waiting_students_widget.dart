import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/cancel_lesson_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class WaitingStudents extends StatefulWidget {
  const WaitingStudents({Key? key, @required this.course, @required this.waitingFirstStudentText, @required this.waitingMoreStudentsText, @required this.waitingStudentsPartnerText, @required this.currentStudentsText})
    : super(key: key); 

  final CourseModel? course;
  final List<ColoredText>? waitingFirstStudentText;
  final List<ColoredText>? waitingMoreStudentsText;
  final List<ColoredText>? waitingStudentsPartnerText;
  final List<ColoredText>? currentStudentsText;

  @override
  State<StatefulWidget> createState() => _WaitingStudentsState();
}

class _WaitingStudentsState extends State<WaitingStudents> {
  Widget _showWaitingStudentsCard() {
    int mentorsCount = 0;
    int studentsCount = 0;
    final List<CourseMentor>? mentors = widget.course?.mentors;
    final List<CourseStudent>? students = widget.course?.students;
    if (mentors != null) {
      mentorsCount = mentors.length;
    }    
    if (students != null) {
      studentsCount = students.length;
    }
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
              if (mentorsCount == 1 && studentsCount == 0) _showWaitingFirstStudentText(),
              if (mentorsCount == 1 && studentsCount > 0) _showWaitingMoreStudentsText(),
              if (mentorsCount > 1) _showWaitingStudentsPartnerText(),
              if (mentorsCount == 1 && studentsCount > 0 || mentorsCount > 1) _showCurrentStudentsText(studentsCount),
              _showCancelButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showWaitingFirstStudentText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 12.0),
      child: MulticolorText(
        coloredTexts: widget.waitingFirstStudentText as List<ColoredText>
      ),
    );
  }  

  Widget _showWaitingMoreStudentsText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 12.0),
      child: MulticolorText(
        coloredTexts: widget.waitingMoreStudentsText as List<ColoredText>
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

  Widget _showCurrentStudentsText(int studentsCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 12.0),
      child: MulticolorText(
        coloredTexts: widget.currentStudentsText as List<ColoredText>
      ),
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
          child: Text('common.cancel_request'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AnimatedDialog(
                widgetInside: CancelLessonRequestDialog()
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