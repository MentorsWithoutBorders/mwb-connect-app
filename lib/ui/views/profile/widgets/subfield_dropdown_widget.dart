import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/skills_widget.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class SubfieldDropdown extends StatefulWidget {
  const SubfieldDropdown({Key? key, @required this.index})
    : super(key: key); 

  final int? index;

  @override
  State<StatefulWidget> createState() => _SubfieldDropdownState();
}

class _SubfieldDropdownState extends State<SubfieldDropdown> {
  ProfileViewModel? _profileProvider;  
  Subfield? _selectedSubfield;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) async {
    final Field? userField = _profileProvider?.user?.field;
    final List<Field>? fields = _profileProvider?.fields;
    _setSelectedSubfield(UtilsFields.getSelectedSubfield(widget.index!, userField, fields) as Subfield);
  }    

  Widget _showSubfieldDropdown() {
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
                    key: Key(AppKeys.subfieldDropdown + widget.index.toString()),
                    dropdownMenuItemList: _buildSubfieldDropdown(),
                    onTapped: _unfocus,
                    onChanged: _changeSubfield,
                    value: _selectedSubfield?.id
                  )
                ),
                if (_selectedSubfield?.id == null) SizedBox.shrink(),
                if (_selectedSubfield?.id != null) Skills(index: widget.index)
              ]
            )
          ),
          _showDeleteSubfield()
        ],
      )
    );
  }

  Widget _showDeleteSubfield() {
    return InkWell(
      key: Key(AppKeys.deleteSubfieldBtn + widget.index.toString()),
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
    _profileProvider?.deleteSubfield(widget.index!);
  }

  List<DropdownMenuItem<String>> _buildSubfieldDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    final Field? userField = _profileProvider?.user?.field;
    final List<Field>? fields = _profileProvider?.fields;    
    List<Subfield>? subfields = UtilsFields.getSubfields(widget.index!, userField, fields);
    for (final Subfield subfield in subfields) {
      items.add(DropdownMenuItem<String>(
        value: subfield.id,
        child: Text(subfield.name as String),
      ));
    }
    return items;
  }  

  void _changeSubfield(String? selectedSubfieldId) {
    final Field? userField = _profileProvider?.user?.field;
    final List<Field>? fields = _profileProvider?.fields;      
    List<Subfield>? subfields = UtilsFields.getSubfields(widget.index!, userField, fields);
    Subfield? selectedSubfield;
    for (final Subfield subfield in subfields) {
      if (subfield.id == selectedSubfieldId) {
        selectedSubfield = Subfield.fromJson(subfield.toJson());
        break;
      }
    } 
    _setSelectedSubfield(selectedSubfield as Subfield);
    _profileProvider?.setSubfield(selectedSubfield, widget.index!);
  }
  
  void _setSelectedSubfield(Subfield subfield) {
    setState(() {
      _selectedSubfield = subfield;
    });
  }

  void _unfocus() {
    _profileProvider?.shouldUnfocus = true;
  }  

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showSubfieldDropdown();
  }
}