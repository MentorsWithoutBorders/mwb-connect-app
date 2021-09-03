import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class FieldDropdown extends StatefulWidget {
  const FieldDropdown({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _FieldDropdownState();
}

class _FieldDropdownState extends State<FieldDropdown> {
  ProfileViewModel? _profileProvider;
  Field? _selectedField;

  Widget _showFieldDropdown() {
    return Container(
      height: 55.0,
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Dropdown(
        key: const Key(AppKeys.fieldDropdown),
        dropdownMenuItemList: _buildFieldDropdown(),
        onTapped: _unfocus,
        onChanged: _changeField,
        value: _selectedField
      ),
    );
  }

  List<DropdownMenuItem<Field>> _buildFieldDropdown() {
    final List<DropdownMenuItem<Field>> items = [];
    List<Field>? fields = _profileProvider?.fields;
    if (fields != null) {
      for (final Field field in fields) {
        items.add(DropdownMenuItem(
          value: field,
          child: Text(field.name as String),
        ));
      }
    }
    return items;
  }  

  void _changeField(Field? field) {
    _setSelectedField(field!);
    _profileProvider?.setField(field);
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
    _setSelectedField(_profileProvider?.getSelectedField() as Field);

    return Wrap(
      children: [
        Label(text: 'profile.field'.tr()),
        _showFieldDropdown()
      ],
    );
  }
}