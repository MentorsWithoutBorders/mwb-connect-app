import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class CourseTypeDropdown extends StatefulWidget {
  const CourseTypeDropdown({Key? key, @required this.courseTypes, @required this.selectedCourseTypeId, @required this.onChange, @required this.unfocus})
    : super(key: key);
    
  final List<CourseType>? courseTypes;
  final String? selectedCourseTypeId;
  final Function(String)? onChange;
  final Function(bool)? unfocus;

  @override
  State<StatefulWidget> createState() => _CourseTypeDropdownState();
}

class _CourseTypeDropdownState extends State<CourseTypeDropdown> {

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 5.0, bottom: 11.0),
      child: Text(
        'student_course.course_type'.tr() + ':',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }  

  Widget _showCourseTypeDropdown() {
    return Wrap(
      children: [
        Container(
          height: 55.0,
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Dropdown<String>(
            dropdownMenuItemList: _buildCourseTypeDropdown(),
            onTapped: _unfocus,
            onChanged: _onChange,
            value: widget.selectedCourseTypeId
          )
        )
      ]
    );
  }

  List<DropdownMenuItem<String>> _buildCourseTypeDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    List<CourseType>? courseTypes = widget.courseTypes;
    if (courseTypes != null) {
      for (final CourseType courseType in courseTypes) {
        String all = 'common.all'.tr();
        all = all[0].toUpperCase() + all.substring(1);
        String name = courseType.id != 'all' ? courseType.duration.toString() + '-' + plural('month', 1) + ' ' + plural('course', 1) : all;
        items.add(DropdownMenuItem(
          value: courseType.id,
          child: Text(name),
        ));
      }
    }
    return items;
  }
  
  void _onChange(String? value) {
    widget.onChange!(value as String);
  }
  
  void _unfocus() {
    widget.unfocus!(true);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        _showTitle(),
        _showCourseTypeDropdown()
      ],
    );
  }
}