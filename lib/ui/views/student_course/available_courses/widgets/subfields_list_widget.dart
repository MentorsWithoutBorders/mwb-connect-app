import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/subfield_item_widget.dart';

class SubfieldsList extends StatefulWidget {
  const SubfieldsList({Key? key, @required this.mentorsNames, @required this.mentorsSubfields})
    : super(key: key); 

  final String? mentorsNames;
  final List<Subfield>? mentorsSubfields;    

  @override
  State<StatefulWidget> createState() => _SubfieldsListState();
}

class _SubfieldsListState extends State<SubfieldsList> with TickerProviderStateMixin {
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
    List<Subfield> subfields = widget.mentorsSubfields ?? [];
    String title = plural('subfield', subfields.length).toString();
    title = title[0].toUpperCase() + title.substring(1) + ':';
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 8.0),
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
    final String mentorsNames = widget.mentorsNames ?? '';
    final List<Subfield>? subfields = widget.mentorsSubfields;
    final List<Widget> subfieldWidgets = [];
    if (subfields != null) {
      for (int i = 0; i < subfields.length; i++) {      
        subfieldWidgets.add(SubfieldItem(
          subfield: subfields[i],
          mentorsNames: mentorsNames
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
    return _showSubfield();
  }
}