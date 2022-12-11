import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class JoinCourseDialog extends StatefulWidget {
  const JoinCourseDialog({Key? key, @required this.course})
    : super(key: key);
    
  final CourseModel? course;    

  @override
  State<StatefulWidget> createState() => _JoinCourseDialogState();
}

class _JoinCourseDialogState extends State<JoinCourseDialog> {
  StudentCourseViewModel? _studentCourseProvider;
  bool _isJoiningCourse = false;  
  
  Widget _showJoinCourseDialogDialog() {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Text(
          'available_mentors.lesson_start_time'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        ),
      )
    );
  }

  Widget _showText() {
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
    String text = 'student_course.join_course_confirmation_text'.tr(args: [courseDuration, mentorsSubfields, mentorsNames, courseDayOfWeek, courseTime, timeZone]);
    String courseStartText = 'course_student.course_start_text'.tr();
    String firstPart = text.substring(0, text.indexOf(courseDuration));
    String secondPart = text.substring(text.indexOf(courseDuration) + courseDuration.length, text.indexOf(mentorsSubfields));
    String thirdPart = text.substring(text.indexOf(mentorsSubfields) + mentorsSubfields.length, text.indexOf(mentorsNames));
    String fourthPart = text.substring(text.indexOf(mentorsNames) + mentorsNames.length, text.indexOf(courseDayOfWeek));

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
                  text: '? ' + '(' + courseStartText + ')'
                )
              ]
            )
          )
        )
      ]
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

  Widget _showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
            child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
          ),
          onTap: () {
            Navigator.pop(context, false);
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 12.0)
          ), 
          onPressed: () async {
            await _joinCourse();
          },
          child: !_isJoiningCourse ? Text(
            'student_course.join_course'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 56.0,
            height: 16.0,
            child: ButtonLoader()
          )
        )
      ]
    ); 
  }

  Future<void> _joinCourse() async {
    setState(() {
      _isJoiningCourse = true;
    });
    await _studentCourseProvider?.joinCourse(widget.course?.id as String);
  }

  @override
  Widget build(BuildContext context) {
    _studentCourseProvider = Provider.of<StudentCourseViewModel>(context);

    return _showJoinCourseDialogDialog();
  }
}