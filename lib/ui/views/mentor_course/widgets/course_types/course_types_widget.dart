import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course_types/course_item_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course_types/edit_course_details_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class CourseTypes extends StatefulWidget {
  const CourseTypes({Key? key, @required this.courseTypes, @required this.selectedCourseType, @required this.subfields, @required this.onSelect, @required this.onSetCourseDetails, @required this.onFindPartner})
    : super(key: key); 

  final List<CourseType>? courseTypes;
  final CourseType? selectedCourseType;
  final List<Subfield>? subfields;
  final Function(String)? onSelect;
  final Function(String, Availability?, String)? onSetCourseDetails;
  final Function? onFindPartner;

  @override
  State<StatefulWidget> createState() => _CourseTypesState();
}

class _CourseTypesState extends State<CourseTypes> {

  Widget _showCourseTypesCard() {
    CourseType? selectedCourseType = widget.selectedCourseType;
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
              _showSelectTitle(),
              _showCourseTypes(),
              if (selectedCourseType?.isWithPartner != null) _showActionButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Center(
        child: Text(
          'mentor_course.start_course'.tr(),
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

  Widget _showSelectTitle() {
    String title = 'mentor_course.course_type_select_title'.tr();
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.0,
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  Widget _showCourseTypes() {
    final List<CourseType>? courseTypes = widget.courseTypes; 
    final CourseType? selectedCourseType = widget.selectedCourseType;   
    final List<Widget> courseTypeWidgets = [];
    if (courseTypes != null) {
      for (int i = 0; i < courseTypes.length; i++) {
        courseTypeWidgets.add(
          CourseTypeItem(
            courseType: courseTypes[i],
            selectedCourseTypeId: selectedCourseType?.id,
            onSelect: widget.onSelect,
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
    bool isWithPartner = widget.selectedCourseType?.isWithPartner as bool;
    String buttonText = isWithPartner ? 'mentor_course.find_partner'.tr() : 'mentor_course.set_course_details'.tr();
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
            if (!isWithPartner) {
              _editCourseDetails();
            } else {
              _findPartner();
            }
          }
        )
      )
    );
  }

  void _editCourseDetails() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: EditCourseDetailsDialog(
          subfields: widget.subfields,
          onSetCourseDetails: widget.onSetCourseDetails
        )
      ),
    );
  }

  void _findPartner() {
    widget.onFindPartner!();
  }

  @override
  Widget build(BuildContext context) {
    return _showCourseTypesCard();
  }
}