import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/subfields_list_widget.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/course_schedule_widget.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/join_course_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class AvailableCourse extends StatefulWidget {
  const AvailableCourse({Key? key, @required this.id, @required this.startDateTime, @required this.fieldName, @required this.mentorsNames, @required this.scheduleText, @required this.mentorsSubfields, @required this.students, @required this.joinText, @required this.onJoin})
    : super(key: key);

  final String? id;
  final DateTime? startDateTime;
  final String? fieldName;
  final String? mentorsNames;
  final String? scheduleText;
  final List<Subfield>? mentorsSubfields;
  final List<CourseStudent>? students;
  final List<ColoredText>? joinText;
  final Function(String)? onJoin;

  @override
  State<StatefulWidget> createState() => _AvailableCourseState();
}

class _AvailableCourseState extends State<AvailableCourse> {
  Widget _showAvailableCourse() {
    return AppCard(
      child: Wrap(
        children: [
          _showMentorsNames(),
          _showFieldName(),
          SubfieldsList(
            mentorsNames: widget.mentorsNames,
            mentorsSubfields: widget.mentorsSubfields
          ),
          CourseSchedule(
            scheduleText: widget.scheduleText
          ),
          _showCurrentStudents(),
          _showJoinCourseButton()
        ],
      )
    );
  }

  Widget _showMentorsNames() {
    String mentorsNames = widget.mentorsNames as String;
    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
      width: double.infinity,
      child: Text(
        mentorsNames,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showFieldName() {
    String fieldName = widget.fieldName as String;
    return Container(
      padding: const EdgeInsets.only(bottom: 7.0),
      width: double.infinity,
      child: Text(
        fieldName,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY,
          height: 1.4
        )
      )
    );
  }

  Widget _showCurrentStudents() {
    int studentsCount = 0;
    final List<CourseStudent>? students = widget.students as List<CourseStudent>;
    if (students != null) {
      studentsCount = students.length;
    }      
    String currentStudentsText = 'common.current_number_students'.tr();
    String courseStartText = 'student_course.start_course_text'.tr();

    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 15.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14.0,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: currentStudentsText + ': ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.TANGO
              )
            ),
            TextSpan(
              text: studentsCount.toString(),
            ),
            TextSpan(
              text: ' (' + courseStartText + ')'
            )
          ]
        )
      )
    );
  }  
  
  Widget _showJoinCourseButton() {
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
            padding: const EdgeInsets.fromLTRB(25.0, 3.0, 25.0, 3.0),
          ), 
          child: Text('student_course.join_course'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            _showJoinCourseDialog();
          }
        )
      )
    );
  }
  
  void _showJoinCourseDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: JoinCourseDialog(
          id: widget.id,
          text: widget.joinText,
          onJoin: widget.onJoin
        )
      ),
    ).then((course) {
      if (course != null) {
        Navigator.pop(context, course);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showAvailableCourse();
  }
}