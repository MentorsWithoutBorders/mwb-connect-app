import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course_view_model.dart';

class CourseTypeItem extends StatefulWidget {
  const CourseTypeItem({Key? key, @required this.courseType})
    : super(key: key); 

  final CourseType? courseType;

  @override
  State<StatefulWidget> createState() => _CourseTypeItemState();
}

class _CourseTypeItemState extends State<CourseTypeItem> {
  MentorCourseViewModel? _mentorCourseProvider;

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
              _setOption(widget.courseType?.id);
            }
          )
        )
      ]
    );
  }

  Widget _showRadioButton() {
    return SizedBox(
      width: 40.0,
      height: 30.0,
      child: Radio<String>(
        value: widget.courseType?.id as String,
        groupValue: _mentorCourseProvider?.selectedCourseType?.id,
        onChanged: (String? value) {
          _setOption(value);
        }
      )
    );
  }

  void _setOption(String? value) {
    _mentorCourseProvider?.setSelectedCourseType(widget.courseType);
    _mentorCourseProvider?.setErrorMessage('');
  }

  Widget _showDescription() {
    final int duration = widget.courseType?.duration as int;
    final bool isWithPartner = widget.courseType?.isWithPartner as bool;
    final String withOrWithout = isWithPartner ? 'common.with'.tr() : 'common.without'.tr();
    final String? description = 'mentor_course.course_description'.tr(args: [duration.toString(), withOrWithout]); 
    return Container(
      width: 200.0,
      child: Text(
        '$description:',
        style: const TextStyle(
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);

    return _showCourseTypeItem();
  }
}