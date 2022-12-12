import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_partner_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class FieldDropdown extends StatefulWidget {
  const FieldDropdown({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _FieldDropdownState();
}

class _FieldDropdownState extends State<FieldDropdown> {
  AvailablePartnerMentorsViewModel? _availablePartnerMentorsProvider;
  Field? _selectedField;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) {
    _setSelectedField(_availablePartnerMentorsProvider?.getSelectedField() as Field);
  }    

  Widget _showFieldDropdown() {
    return Wrap(
      children: [
        if (_selectedField?.id != null) Container(
          height: 55.0,
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Dropdown<String>(
            dropdownMenuItemList: _buildFieldDropdown(),
            onTapped: _unfocus,
            onChanged: _changeField,
            value: _selectedField?.id
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildFieldDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    List<Field>? fields = _availablePartnerMentorsProvider?.fields;
    if (fields != null) {
      for (final Field field in fields) {
        items.add(DropdownMenuItem(
          value: field.id,
          child: Text(field.name as String),
        ));
      }
    }
    return items;
  }  

  void _changeField(String? selectedFieldId) async {
    List<Field>? fields = _availablePartnerMentorsProvider?.fields;
    Field? selectedField;
    if (fields != null) {
      for (final Field field in fields) {
        if (field.id == selectedFieldId) {
          selectedField = Field.fromJson(field.toJson());
          break;
        }
      }
    }
    _setSelectedField(selectedField as Field);
    _availablePartnerMentorsProvider?.setField(selectedField);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    List<Subfield>? filterSubfields = _availablePartnerMentorsProvider?.filterField.subfields;
    if (filterSubfields != null && filterSubfields.length == 0) {
      _availablePartnerMentorsProvider?.addSubfield();
    }
  }
  
  void _setSelectedField(Field field) {
    setState(() {
      _selectedField = field;
    });
  }

  void _unfocus() {
    _availablePartnerMentorsProvider?.shouldUnfocus = true;
  }

  @override
  Widget build(BuildContext context) {
    _availablePartnerMentorsProvider = Provider.of<AvailablePartnerMentorsViewModel>(context);

    return Wrap(
      children: [
        Label(text: 'common.field'.tr()),
        _showFieldDropdown()
      ],
    );
  }
}