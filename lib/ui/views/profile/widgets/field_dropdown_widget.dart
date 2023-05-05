import 'package:flutter/material.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentor_course_view_model.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/ui/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class FieldDropdown extends StatefulWidget {
  const FieldDropdown({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _FieldDropdownState();
}

class _FieldDropdownState extends State<FieldDropdown> {
  ProfileViewModel? _profileProvider;
  MentorCourseViewModel? _mentorCourseProvider;
  Field? _selectedField;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) {
    _setSelectedField(_profileProvider?.getSelectedField() as Field);
  }    

  Widget _showFieldDropdown() {
    return Wrap(
      children: [
        if (_selectedField?.id != null) Container(
          height: 55.0,
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Dropdown<String>(
            key: const Key(AppKeys.fieldDropdown),
            dropdownMenuItemList: _buildFieldDropdown(),
            onTapped: _unfocus,
            onChanged: _changeField,
            value: _selectedField?.id
          ),
        ),
        if (_selectedField?.id == null) SizedBox(
          height: 55.0,
        )
      ]
    );
  }

  List<DropdownMenuItem<String>> _buildFieldDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    List<Field>? fields = _profileProvider?.fields;
    if (fields != null) {
      for (final Field field in fields) {
        String? fieldName = field.name == 'Other' ? 'Choose field' : field.name;
        items.add(DropdownMenuItem(
          value: field.id as String,
          child: Text(fieldName as String),
        ));
      }
    }
    return items;
  }  

  void _changeField(String? selectedFieldId) {
    List<Field>? fields = _profileProvider?.fields;
    Field selectedField = Field();
    if (fields != null) {
      for (final Field field in fields) {
        if (field.id == selectedFieldId) {
          selectedField = Field.fromJson(field.toJson());
          break;
        }
      }
    }    
    _setSelectedField(selectedField);
    _profileProvider?.setField(selectedField);
    if (_profileProvider?.user?.isMentor == true) {
      _mentorCourseProvider?.setField(selectedField);
    }
  }
  
  void _setSelectedField(Field field) {
    setState(() {
      _selectedField = field;
    });
  }

  void _unfocus() {
    _profileProvider?.shouldUnfocus = true;
  }

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);

    return Wrap(
      children: [
        Label(text: 'common.field'.tr()),
        _showFieldDropdown()
      ],
    );
  }
}