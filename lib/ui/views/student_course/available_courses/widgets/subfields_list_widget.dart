import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/subfield_item_widget.dart';

class SubfieldsList extends StatefulWidget {
  const SubfieldsList({Key? key, @required this.course})
    : super(key: key); 

  final CourseModel? course;

  @override
  State<StatefulWidget> createState() => _SubfieldsListState();
}

class _SubfieldsListState extends State<SubfieldsList> with TickerProviderStateMixin {
  StudentCourseViewModel? _studentCourseProvider;

  Widget _showSubfield() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showTitle(),
        _showSubfieldsList()
      ]
    );
  }

  Widget _showTitle() {
    List<Subfield> subfields = _studentCourseProvider?.getMentorsSubfields() as List<Subfield>;
    String title = plural('subfield', subfields.length).toString();
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

  Widget _showSubfieldsList() {
    final List<String> mentorsNames = _studentCourseProvider?.getMentorsNames() as List<String>;
    final List<Subfield>? subfields = _studentCourseProvider?.getMentorsSubfields();
    final List<Widget> subfieldWidgets = [];
    if (subfields != null) {
      for (int i = 0; i < subfields.length; i++) {
        String mentorName = mentorsNames[i];
        if (mentorsNames.length > subfields.length) {
          mentorName = mentorsNames.join(' ' + 'common.and'.tr() + ' ');
        }        
        subfieldWidgets.add(SubfieldItem(
          subfield: subfields[i],
          mentorName: mentorName
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Wrap(
        children: subfieldWidgets
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _studentCourseProvider = Provider.of<StudentCourseViewModel>(context);

    return _showSubfield();
  }
}