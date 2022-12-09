import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/cancel_course_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class WaitingStartCourse extends StatefulWidget {
  const WaitingStartCourse({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _WaitingStartCourseState();
}

class _WaitingStartCourseState extends State<WaitingStartCourse> {
  StudentCourseViewModel? _studentCourseProvider;  

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
    if (_studentCourseProvider?.isCourse == false) {
      return SizedBox.shrink();
    }
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');    
    CourseModel? course = _studentCourseProvider?.course;
    String courseDuration = course?.type?.duration.toString() as String;
    CourseMentor mentor = course?.mentors?[0] as CourseMentor;
    CourseMentor? partnerMentor = course?.mentors?[1];
    String mentorsSubfields = _getMentorsSubfields(mentor, partnerMentor);
    String mentorsNames = _getMentorsNames(mentor, partnerMentor);
    String courseDayOfWeek = dayOfWeekFormat.format(course?.startDateTime as DateTime);
    String courseTime = timeFormat.format(course?.startDateTime as DateTime);
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String text = 'student_course.waiting_course_text'.tr(args: [courseDuration, mentorsSubfields, mentorsNames, courseDayOfWeek, courseTime, timeZone]);
    String firstPart = text.substring(0, text.indexOf(courseDuration));
    String secondPart = text.substring(text.indexOf(courseDuration) + courseDuration.length, text.indexOf(mentorsSubfields));
    String thirdPart = text.substring(text.indexOf(mentorsSubfields) + mentorsSubfields.length, text.indexOf(mentorsNames));
    String fourthPart = text.substring(text.indexOf(mentorsNames) + mentorsNames.length, text.indexOf(courseDayOfWeek));
    String fifthPart = text.substring(text.indexOf(timeZone) + timeZone.length);

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 15.0),
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
                  text: firstPart
                ),
                TextSpan(
                  text: courseDuration,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: secondPart
                ),
                TextSpan(
                  text: mentor.field!.subfields![0].name,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                if (partnerMentor != null) TextSpan(
                  text: ' ' + 'common.and'.tr() + ' '
                ),
                if (partnerMentor != null) TextSpan(
                  text: partnerMentor.field!.subfields![0].name,
                ),
                TextSpan(
                  text: thirdPart
                ),
                TextSpan(
                  text: mentor.name,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                if (partnerMentor != null) TextSpan(
                  text: ' ' + 'common.and'.tr() + ' '
                ),
                if (partnerMentor != null) TextSpan(
                  text: partnerMentor.name,
                ),
                TextSpan(
                  text: fourthPart
                ),
                TextSpan(
                  text: courseDayOfWeek,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: ' ' + at + ' '
                ),
                TextSpan(
                  text: courseTime + ' ' + timeZone,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: fifthPart
                )
              ]
            )
          )
        ),
        _showCurrentStudentsText()        
      ],
    );
  }

  String _getMentorsNames(CourseMentor mentor, CourseMentor? partnerMentor) {
    String mentorsNames = '';
    if (partnerMentor != null) {
      mentorsNames = mentor.name! + ' ' + 'common.and'.tr() + ' ' + partnerMentor.name!;
    } else {
      mentorsNames = mentor.name!;
    }
    return mentorsNames;
  }
  
  String _getMentorsSubfields(CourseMentor mentor, CourseMentor? partnerMentor) {
    String mentorsSubfields = '';
    if (partnerMentor != null) {
      mentorsSubfields = mentor.field!.subfields![0].name! + ' ' + 'common.and'.tr() + ' ' + partnerMentor.field!.subfields![0].name!;
    } else {
      mentorsSubfields = mentor.field!.subfields![0].name!;
    }
    return mentorsSubfields;
  }

  Widget _showCurrentStudentsText() {
    int studentsCount = 0;
    final List<CourseStudent>? students = _studentCourseProvider?.course?.students;
    if (students != null) {
      studentsCount = students.length;
    }      
    String text = 'common.current_number_students'.tr();

    return Wrap(
      children: [
        Padding(
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
                  text: text + ': '
                ),
                TextSpan(
                  text: studentsCount.toString(),
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                )
              ]
            )
          )
        )
      ]
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
              builder: (_) => const AnimatedDialog(
                widgetInside: CancelCourseDialog()
              )
            ); 
          }
        ),
      ),
    );
  } 

  @override
  Widget build(BuildContext context) {
    _studentCourseProvider = Provider.of<StudentCourseViewModel>(context);

    return _showWaitingStartCourseCard();
  }
}