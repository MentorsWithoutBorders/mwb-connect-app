import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests_filters/widgets/skills_widget.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class SubfieldDropdown extends StatefulWidget {
  const SubfieldDropdown({Key? key, this.index, this.filterField, this.field, this.onDelete, this.onSet, this.onAddSkill, this.onDeleteSkill, this.onSetScrollOffset, this.onSetShouldUnfocus})
    : super(key: key); 

  final int? index;
  final Field? filterField;
  final Field? field;
  final Function(int)? onDelete;
  final Function (Subfield, int)? onSet;
  final Function(String, int)? onAddSkill;
  final Function(String, int)? onDeleteSkill;
  final Function(double, double, double)? onSetScrollOffset;  
  final Function (bool)? onSetShouldUnfocus;

  @override
  State<StatefulWidget> createState() => _SubfieldDropdownState();
}

class _SubfieldDropdownState extends State<SubfieldDropdown> {
  Subfield? _selectedSubfield;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) {
    Field filterField = widget.filterField as Field;
    Field field = widget.field as Field;
    Subfield? selectedSubfield = UtilsFields.getSelectedSubfield(widget.index!, filterField, [field]);
    if (selectedSubfield != null) {
      _setSelectedSubfield(selectedSubfield);
    }
  }     

  Widget _showSubfieldDropdown() {
    Field filterField = widget.filterField as Field;
    Field field = widget.field as Field;
    final List<String>? skills = UtilsFields.getSkillSuggestions('', widget.index!, filterField, [field]);
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                if (_selectedSubfield?.id != null) Container(
                  height: 50.0,
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Dropdown<String>(
                    dropdownMenuItemList: _buildSubfieldDropdown(),
                    onTapped: _unfocus,
                    onChanged: _changeSubfield,
                    value: _selectedSubfield?.id
                  ),
                ),
                if (_selectedSubfield?.id == null) SizedBox.shrink(),
                if (_selectedSubfield?.id != null && skills != null && skills.length > 0) Skills(
                  index: widget.index,
                  filterField: widget.filterField,
                  field: widget.field,
                  onAdd: widget.onAddSkill,
                  onDelete: widget.onDeleteSkill,
                  onSetScrollOffset: widget.onSetScrollOffset
                )
              ]
            )
          ),
          _showDeleteSubfield()
        ]
      )
    );
  }

  Widget _showDeleteSubfield() {
    return InkWell(
      child: Container(
        width: 30.0,
        height: 40.0,
        child: Image.asset(
          'assets/images/delete_icon.png'
        ),
      ),
      onTap: () {
        _deleteSubfield();
      }                 
    );
  }

  void _deleteSubfield() {
    _unfocus();
    widget.onDelete!(widget.index!);
  }

  List<DropdownMenuItem<String>> _buildSubfieldDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    Field filterField = widget.filterField as Field;
    Field field = widget.field as Field;
    List<Subfield> subfields = UtilsFields?.getSubfields(widget.index!, filterField, [field]);
    for (final Subfield subfield in subfields) {
      items.add(DropdownMenuItem<String>(
        value: subfield.id,
        child: Text(subfield.name as String),
      ));
    }
    return items;
  }  

  void _changeSubfield(String? selectedSubfieldId) {
    Field filterField = widget.filterField as Field;
    final Field field = widget.field as Field;
    List<Subfield>? subfields = UtilsFields.getSubfields(widget.index!, filterField, [field]);
    Subfield? selectedSubfield;
    for (final Subfield subfield in subfields) {
      if (subfield.id == selectedSubfieldId) {
        selectedSubfield = Subfield.fromJson(subfield.toJson());
        break;
      }
    }     
    _setSelectedSubfield(selectedSubfield as Subfield);
    widget.onSet!(selectedSubfield, widget.index!);
  }

  void _setSelectedSubfield(Subfield subfield) {
    setState(() {
      _selectedSubfield = subfield;
    });
  }

  void _unfocus() {
    widget.onSetShouldUnfocus!(true);
  }  

  @override
  Widget build(BuildContext context) {
    return _showSubfieldDropdown();
  }
}