import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';

class CourseTypeItem extends StatelessWidget {
  const CourseTypeItem({Key? key, @required this.courseType, @required this.selectedCourseTypeId, @required this.onSelect})
    : super(key: key); 

  final CourseType? courseType;
  final String? selectedCourseTypeId;
  final Function(String)? onSelect;

  Widget _showCourseTypeItem() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            child: Row(
              children: [
                _showRadioButton(),
                _showDescription(),
              ]
            ),
            onTap: () {
              _setOption(courseType?.id);
            }
          )
        )
      ]
    );
  }

  Widget _showRadioButton() {
    return SizedBox(
      width: 40.0,
      height: 25.0,
      child: Radio<String>(
        value: courseType?.id as String,
        groupValue: selectedCourseTypeId,
        onChanged: (String? value) {
          _setOption(value);
        }
      )
    );
  }

  void _setOption(String? value) {
    onSelect!(courseType?.id as String);
  }

  Widget _showDescription() {
    final int duration = courseType?.duration as int;
    final bool isWithPartner = courseType?.isWithPartner as bool;
    final String withOrWithout = isWithPartner ? 'common.with'.tr() : 'common.without'.tr();
    final String? description = 'mentor_course.course_description'.tr(args: [duration.toString(), withOrWithout]); 
    return Container(
      child: Text(
        '$description',
        style: const TextStyle(
          fontSize: 13.0,
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showCourseTypeItem();
  }
}