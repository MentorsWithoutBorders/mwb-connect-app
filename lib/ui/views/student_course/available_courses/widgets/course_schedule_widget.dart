import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';

class CourseSchedule extends StatefulWidget {
  const CourseSchedule({Key? key, @required this.course})
    : super(key: key); 

  final CourseModel? course;

  @override
  State<StatefulWidget> createState() => _CourseScheduleState();
}

class _CourseScheduleState extends State<CourseSchedule> with TickerProviderStateMixin {
  Widget _showCourseSchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showTitle(),
        _showSchedule()
      ]
    );
  }

  Widget _showTitle() {
    String title = 'student_course.schedule'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showSchedule() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          _showBullet(),
          _showScheduleDetails()
        ]
      )
    );
  }

  Widget _showScheduleDetails() {
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');  
    String courseDayOfWeek = dayOfWeekFormat.format(widget.course?.startDateTime as DateTime);
    String courseTime = timeFormat.format(widget.course?.startDateTime as DateTime);
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String courseSchedule = plural(courseDayOfWeek, 2) + ' ' + 'common.at'.tr() + courseTime + ' ' + timeZone;
    return Text(
      courseSchedule,
      style: const TextStyle(
        fontSize: 13.0,
        color: AppColors.DOVE_GRAY
      )
    );
  }  

  Widget _showBullet() {
    return Container(
      width: 8.0,
      height: 8.0,
      margin: const EdgeInsets.only(right: 10.0),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.MONZA
      )
    );
  }  

  @override
  Widget build(BuildContext context) {
    return _showCourseSchedule();
  }
}