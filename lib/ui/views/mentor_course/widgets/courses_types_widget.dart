import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/edit_course_details_dialog_widget.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course_item_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class CoursesTypes extends StatefulWidget {
  const CoursesTypes({Key? key, @required this.coursesTypes, @required this.selectedCourseType, @required this.subfields, @required this.setSelectedCourseTypeCallback, @required this.setCourseDetailsCallback})
    : super(key: key); 

  final List<CourseType>? coursesTypes;
  final CourseType? selectedCourseType;
  final List<Subfield>? subfields;
  final Function(String)? setSelectedCourseTypeCallback;
  final Function(String, Availability?, String)? setCourseDetailsCallback;    

  @override
  State<StatefulWidget> createState() => _CoursesTypesState();
}

class _CoursesTypesState extends State<CoursesTypes> {

  Widget _showCourseType() {
    CourseType? selectedCourseType = widget.selectedCourseType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showTitle(),
        _showCoursesTypes(),
        if (selectedCourseType?.isWithPartner != null) _showActionButton()
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
    final CourseType? selectedCourseType = widget.selectedCourseType;   
    final List<Widget> courseTypeWidgets = [];
    if (coursesTypes != null) {
      for (int i = 0; i < coursesTypes.length; i++) {
        courseTypeWidgets.add(
          CourseTypeItem(
            courseType: coursesTypes[i],
            selectedCourseTypeId: selectedCourseType?.id,
            setSelectedCourseTypeCallback: widget.setSelectedCourseTypeCallback,
          )
        );
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
    String buttonText = widget.selectedCourseType?.isWithPartner as bool ? 'mentor_course.find_partner'.tr() : 'mentor_course.wait_students'.tr();
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
            showDialog(
              context: context,
              builder: (_) => AnimatedDialog(
                widgetInside: EditCourseDetailsDialog(
                  selectedCourseType: widget.selectedCourseType,
                  subfields: widget.subfields,
                  setCourseDetailsCallback: widget.setCourseDetailsCallback
                )
              ),
            );
          }
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showCourseType();
  }
}