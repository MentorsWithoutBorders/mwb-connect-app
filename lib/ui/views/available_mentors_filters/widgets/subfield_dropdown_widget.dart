import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors_filters/widgets/skills_widget.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class SubfieldDropdown extends StatefulWidget {
  const SubfieldDropdown({Key? key, @required this.index})
    : super(key: key); 

  final int? index;

  @override
  State<StatefulWidget> createState() => _SubfieldDropdownState();
}

class _SubfieldDropdownState extends State<SubfieldDropdown> {
  AvailableMentorsViewModel? _availableMentorsProvider;  
  Subfield? _selectedSubfield;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) {
    List<Field> fields = _availableMentorsProvider?.fields as List<Field>;
    Field filterField = _availableMentorsProvider?.filterField as Field;
    Subfield? selectedSubfield = UtilsFields.getSelectedSubfield(widget.index!, filterField, fields);
    if (selectedSubfield != null) {
      _setSelectedSubfield(selectedSubfield);
    }
  }     

  Widget _showSubfieldDropdown() {
    List<Field> fields = _availableMentorsProvider?.fields as List<Field>;
    Field filterField = _availableMentorsProvider?.filterField as Field;
    final List<String>? skills = UtilsFields.getSkillSuggestions('', widget.index!, filterField, fields);
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    if (_selectedSubfield != null) Container(
                      height: 50.0,
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Dropdown<Subfield>(
                        dropdownMenuItemList: _buildSubfieldDropdown(),
                        onTapped: _unfocus,
                        onChanged: _changeSubfield,
                        value: _selectedSubfield
                      ),
                    ),
                    if (_selectedSubfield == null) SizedBox.shrink(),
                    if (_selectedSubfield != null && skills != null && skills.length > 0) Skills(index: widget.index)
                  ]
                )
              ),
              _showDeleteSubfield()
            ]
          )
        ],
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

  void _deleteSubfield() async {
    _unfocus();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    _availableMentorsProvider?.deleteSubfield(widget.index!);
  }

  List<DropdownMenuItem<Subfield>> _buildSubfieldDropdown() {
    final List<DropdownMenuItem<Subfield>> items = [];
    List<Field> fields = _availableMentorsProvider?.fields as List<Field>;
    Field filterField = _availableMentorsProvider?.filterField as Field;
    List<Subfield> subfields = UtilsFields?.getSubfields(widget.index!, filterField, fields);
    for (final Subfield subfield in subfields) {
      items.add(DropdownMenuItem<Subfield>(
        value: subfield,
        child: Text(subfield.name as String),
      ));
    }
    return items;
  }  

  void _changeSubfield(Subfield? subfield) {
    _setSelectedSubfield(subfield!);
    _availableMentorsProvider?.setSubfield(Subfield(id: subfield.id, name: subfield.name), widget.index!);
  }
  
  void _setSelectedSubfield(Subfield subfield) {
    setState(() {
      _selectedSubfield = subfield;
    });
  }

  void _unfocus() {
    _availableMentorsProvider?.shouldUnfocus = true;
  }  

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return _showSubfieldDropdown();
  }
}