import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course_item_widget.dart';

class CoursesTypes extends StatefulWidget {
  const CoursesTypes({Key? key, @required this.coursesTypes})
    : super(key: key); 

  final List<CourseType>? coursesTypes;

  @override
  State<StatefulWidget> createState() => _CoursesTypesState();
}

class _CoursesTypesState extends State<CoursesTypes> {
  MentorCourseViewModel? _mentorCourseProvider;

  Widget _showCourseType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showTitle(),
        _showCoursesTypes(),
        if (_mentorCourseProvider!.selectedCourseType?.isWithPartner != null) _showActionButton()
      ]
    );
  }

  Widget _showTitle() {
    String title = 'mentor_course.course_type_title'.tr();
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

  Widget _showCoursesTypes() {
    final List<CourseType>? coursesTypes = widget.coursesTypes;    
    final List<Widget> courseTypeWidgets = [];
    if (coursesTypes != null) {
      for (int i = 0; i < coursesTypes.length; i++) {
        courseTypeWidgets.add(CourseTypeItem(courseType: coursesTypes[i]));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Wrap(
        children: courseTypeWidgets
      )
    );
  }

  Widget _showActionButton() {
    String buttonText = _mentorCourseProvider!.selectedCourseType?.isWithPartner as bool ? 'mentor_course.find_partner'.tr() : 'mentor_course.wait_students'.tr();
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
            buttonText,
            style: const TextStyle(color: Colors.white)
          ),
          onPressed: () async {
 
          }
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);

    return _showCourseType();
  }
}