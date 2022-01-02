import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/subfield_item_widget.dart';

class SubfieldsList extends StatefulWidget {
  const SubfieldsList({Key? key, @required this.mentorId, @required this.subfields})
    : super(key: key); 

  final String? mentorId;
  final List<Subfield>? subfields;

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
    String title = 'available_mentors.choose_subfield'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showSubfieldsList() {
    final List<Widget> subfieldWidgets = [];
    if (widget.subfields != null) {
      for (int i = 0; i < widget.subfields!.length; i++) {
        String mentorId = widget.mentorId as String;
        String id = mentorId + '-s-' + i.toString();
        subfieldWidgets.add(SubfieldItem(id: id, subfield: widget.subfields![i]));
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