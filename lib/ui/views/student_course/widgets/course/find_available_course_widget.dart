import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class FindAvailableCourse extends StatefulWidget {
  const FindAvailableCourse({Key? key, @required this.onFind})
    : super(key: key);
    
  final Function? onFind;

  @override
  State<StatefulWidget> createState() => _FindAvailableCourseState();
}

class _FindAvailableCourseState extends State<FindAvailableCourse> with TickerProviderStateMixin {
  Widget _showFindAvailableCourseCard() {
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
              _showTitle(),
              Container(
                padding: const EdgeInsets.only(left: 3.0),
                child: Wrap(
                  children: [
                    _showTopText(),
                    _showFindCourseButton()
                  ]
                )
              )
            ],
          )
        ),
      ),
    );
  }

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(top: 3.0, bottom: 15.0),
      child: Center(
        child: Text(
          'student_course.find_available_course'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.TANGO,
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }   

  Widget _showTopText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        'student_course.select_course_text'.tr(),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 12.0,
          color: AppColors.DOVE_GRAY,
          height: 1.4
        ),
      )
    );
  }

  Widget _showFindCourseButton() {
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
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ),
          child: Text(
            'student_course.find_course'.tr(),
            style: const TextStyle(color: Colors.white)
          ),
          onPressed: () async {
            widget.onFind!();
          }
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showFindAvailableCourseCard();
  }
}