import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/cancel_lesson_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class WaitingStudents extends StatefulWidget {
  const WaitingStudents({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _WaitingStudentsState();
}

class _WaitingStudentsState extends State<WaitingStudents> {
  MentorCourseViewModel? _mentorCourseProvider;  

  Widget _showWaitingStudentsCard() {
    int mentorsCount = 0;
    int studentsCount = 0;
    final List<CourseMentor>? mentors = _mentorCourseProvider?.course?.mentors;
    final List<CourseStudent>? students = _mentorCourseProvider?.course?.students;
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
    String minStudentsCourse = AppConstants.minStudentsCourse.toString();
    String maxStudentsCourse = AppConstants.maxStudentsCourse.toString();
    int courseDuration = _mentorCourseProvider?.course?.type?.duration as int;
    String text = 'mentor_course.waiting_first_student'.tr(args: [minStudentsCourse, courseDuration.toString(), maxStudentsCourse]);
    String firstPart = text.substring(0, text.indexOf(minStudentsCourse));
    String secondPart = text.substring(text.indexOf(minStudentsCourse) + minStudentsCourse.length, text.indexOf(maxStudentsCourse));

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
                  text: firstPart
                ),
                TextSpan(
                  text: minStudentsCourse,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: secondPart
                ),
                TextSpan(
                  text: maxStudentsCourse,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: '.'
                )
              ]
            )
          )
        )
      ]
    );
  }  

  Widget _showWaitingMoreStudentsText() {
    final DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    final DateFormat timeFormat = DateFormat(AppConstants.timeFormat, 'en');
    String minStudentsCourse = AppConstants.minStudentsCourse.toString();
    String maxStudentsCourse = AppConstants.maxStudentsCourse.toString();
    int courseDuration = _mentorCourseProvider?.course?.type?.duration as int;
    DateTime courseStartDateTime = _mentorCourseProvider?.course?.startDateTime as DateTime;
    String courseDayOfWeek = dayOfWeekFormat.format(courseStartDateTime);
    String courseTime = timeFormat.format(courseStartDateTime);
    DateTime now = DateTime.now();    
    String timeZone = now.timeZoneName;
    String text = 'mentor_course.waiting_more_students'.tr(args: [courseDuration.toString(), minStudentsCourse, courseDayOfWeek, courseTime, timeZone, maxStudentsCourse]);
    String firstPart = text.substring(0, text.indexOf(courseDuration.toString()));
    String secondPart = text.substring(text.indexOf(courseDuration.toString()) + courseDuration.toString().length, text.indexOf(minStudentsCourse));
    String thirdPart = text.substring(text.indexOf(minStudentsCourse.toString()) + minStudentsCourse.toString().length, text.indexOf(courseDayOfWeek));
    String fourthPart = text.substring(text.indexOf(courseTime) + courseTime.length, text.indexOf(maxStudentsCourse));
    String at = 'common.at'.tr();

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
                  text: firstPart
                ),
                TextSpan(
                  text: courseDuration.toString(),
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: secondPart
                ),
                TextSpan(
                  text: minStudentsCourse,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: thirdPart
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
                  text: fourthPart
                ),
                TextSpan(
                  text: maxStudentsCourse,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: '.'
                )
              ]
            )
          )
        )
      ]
    );
  }

  Widget _showWaitingStudentsPartnerText() {
    final DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    final DateFormat timeFormat = DateFormat(AppConstants.timeFormat, 'en');
    String minStudentsCourse = AppConstants.minStudentsCourse.toString();
    String maxStudentsCourse = AppConstants.maxStudentsCourse.toString();
    int courseDuration = _mentorCourseProvider?.course?.type?.duration as int;
    DateTime courseStartDateTime = _mentorCourseProvider?.course?.startDateTime as DateTime;
    String courseDayOfWeek = dayOfWeekFormat.format(courseStartDateTime);
    String courseTime = timeFormat.format(courseStartDateTime);
    CourseMentor partnerMentor = _mentorCourseProvider?.getPartnerMentor() as CourseMentor;
    String partnerMentorName = partnerMentor.name as String;
    DateTime now = DateTime.now();    
    String timeZone = now.timeZoneName;
    String text = 'mentor_course.waiting_students_partner'.tr(args: [courseDuration.toString(), partnerMentorName, minStudentsCourse, courseDayOfWeek, courseTime, timeZone, maxStudentsCourse]);
    String firstPart = text.substring(0, text.indexOf(courseDuration.toString()));
    String secondPart = text.substring(text.indexOf(courseDuration.toString()) + courseDuration.toString().length, text.indexOf(partnerMentorName));
    String thirdPart = text.substring(text.indexOf(partnerMentorName) + partnerMentorName.length, text.indexOf(minStudentsCourse));
    String fourthPart = text.substring(text.indexOf(minStudentsCourse.toString()) + minStudentsCourse.toString().length, text.indexOf(courseDayOfWeek));
    String fifthPart = text.substring(text.indexOf(courseTime) + courseTime.length, text.indexOf(maxStudentsCourse));
    String at = 'common.at'.tr();

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 12.0),
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
                  text: courseDuration.toString(),
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: secondPart
                ),
                TextSpan(
                  text: partnerMentorName,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: thirdPart
                ),
                TextSpan(
                  text: minStudentsCourse,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
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
                ),
                TextSpan(
                  text: maxStudentsCourse,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: '.'
                )
              ]
            )
          )
        )
      ]
    );
  }

  Widget _showCurrentStudentsText(int studentsCount) {
    String text = 'mentor_course.current_students'.tr();

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
          child: Text('connect_with_mentor.cancel_request'.tr(), style: const TextStyle(color: Colors.white)),
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
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);

    return _showWaitingStudentsCard();
  }
}