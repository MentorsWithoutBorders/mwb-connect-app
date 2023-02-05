import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class CourseSchedule extends StatefulWidget {
  const CourseSchedule({Key? key, @required this.scheduleText})
    : super(key: key); 

  final String? scheduleText;

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
    String title = 'student_course.schedule'.tr() + ':';
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 7.0),
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
    String scheduleText = widget.scheduleText ?? '';
    return Text(
      scheduleText,
      style: const TextStyle(
        fontSize: 14.0,
        color: AppColors.DOVE_GRAY
      )
    );
  }  

  Widget _showBullet() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Container(
        width: 8.0,
        height: 8.0,
        margin: const EdgeInsets.only(right: 10.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.SILVER
        )
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    return _showCourseSchedule();
  }
}