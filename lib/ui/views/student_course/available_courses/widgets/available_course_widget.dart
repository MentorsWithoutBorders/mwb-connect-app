import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/subfields_list_widget.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/course_schedule_widget.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/join_course_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';


class AvailableCourse extends StatefulWidget {
  const AvailableCourse({Key? key, @required this.course})
    : super(key: key); 

  final CourseModel? course;

  @override
  State<StatefulWidget> createState() => _AvailableCourseState();
}

class _AvailableCourseState extends State<AvailableCourse> {
  StudentCourseViewModel? _studentCourseProvider;

  Widget _showAvailableCourse() {
    return AppCard(
      child: Wrap(
        children: [
          _showMentorsNames(),
          _showFieldName(),
          SubfieldsList(course: widget.course),
          CourseSchedule(course: widget.course),
          _showCurrentStudents(),
          _showJoinCourseButton()
        ],
      )
    );
  }

  Widget _showMentorsNames() {
    List<String> mentorsNames = _studentCourseProvider?.getMentorsNames() as List<String>;
    String mentorsNamesString = mentorsNames.join(' ' + 'common.and'.tr() + ' ');
    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
      width: double.infinity,
      child: Text(
        mentorsNamesString,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showFieldName() {
    String fieldName = _studentCourseProvider?.getFieldName() ?? '';
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
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
    final List<CourseStudent>? students = _studentCourseProvider?.course?.students;
    if (students != null) {
      studentsCount = students.length;
    }      
    String currentStudentsText = 'common.current_number_students'.tr();
    String courseStartText = 'course_student.course_start_text'.tr();

    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 10.0, 12.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: currentStudentsText + ': '
            ),
            TextSpan(
              text: studentsCount.toString(),
              style: const TextStyle(
                color: AppColors.TANGO
              )
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
        widgetInside: JoinCourseDialog(course: widget.course)
      ),
    ); 
  }

  @override
  Widget build(BuildContext context) {
    _studentCourseProvider = Provider.of<StudentCourseViewModel>(context);
    
    return _showAvailableCourse();
  }
}