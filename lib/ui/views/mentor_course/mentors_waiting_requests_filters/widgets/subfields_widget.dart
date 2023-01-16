import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests_filters/widgets/subfield_dropdown_widget.dart';

class Subfields extends StatefulWidget {
  const Subfields({Key? key, this.field, this.filterField, this.onAdd, this.onDelete, this.onSet, this.onAddSkill, this.onDeleteSkill, this.onSetScrollOffset, this.onSetShouldUnfocus})
    : super(key: key);
    
  final Field? filterField;
  final Field? field;
  final Function? onAdd;
  final Function(int)? onDelete;
  final Function (Subfield, int)? onSet;
  final Function(String, int)? onAddSkill;
  final Function(String, int)? onDeleteSkill;
  final Function(double, double, double)? onSetScrollOffset;    
  final Function (bool)? onSetShouldUnfocus;    

  @override
  State<StatefulWidget> createState() => _SubfieldsState();
}

class _SubfieldsState extends State<Subfields> {
  Widget _showSubfields() {
    final List<Widget> subfieldWidgets = [];
    final List<Subfield>? filterSubfields = widget.filterField?.subfields;
    subfieldWidgets.add(Label(text: 'common.subfields'.tr()));
    if (filterSubfields != null) {
      for (int i = 0; i < filterSubfields.length; i++) {
        final Widget subfield = SubfieldDropdown(
          index: i,
          filterField: widget.filterField,
          field: widget.field,
          onDelete: widget.onDelete,
          onSet: widget.onSet,
          onAddSkill: widget.onAddSkill,
          onDeleteSkill: widget.onDeleteSkill,
          onSetScrollOffset: widget.onSetScrollOffset,
          onSetShouldUnfocus: widget.onSetShouldUnfocus
        );
        subfieldWidgets.add(subfield);
      }
    }
    subfieldWidgets.add(_showAddSubfieldButton());
    return Wrap(children: subfieldWidgets);
  }

  Widget _showAddSubfieldButton() {
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(top: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0)
          ), 
          child: Text('common.add_subfield'.tr(), style: TextStyle(color: Colors.white)),
          onPressed: () {
            _addSubfield();
          }
        ),
      ),
    );
  }

  void _addSubfield() {
    _unfocus();
    widget.onAdd!();
  }

  void _unfocus() {
    widget.onSetShouldUnfocus!(true);
  }
  
  @override
  Widget build(BuildContext context) {
    return _showSubfields();
  }
}