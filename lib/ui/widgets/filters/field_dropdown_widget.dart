import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class FieldDropdown extends StatefulWidget {
  const FieldDropdown({Key? key, @required this.fields, @required this.selectedField, @required this.onChange, @required this.unfocus})
    : super(key: key);
    
  final List<Field>? fields;
  final Field? selectedField;
  final Function(String)? onChange;
  final Function(bool)? unfocus;

  @override
  State<StatefulWidget> createState() => _FieldDropdownState();
}

class _FieldDropdownState extends State<FieldDropdown> {

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 5.0, bottom: 11.0),
      child: Text(
        'common.field'.tr() + ':',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }  

  Widget _showFieldDropdown() {
    Field? selectedField = widget.selectedField;
    return Wrap(
      children: [
        if (selectedField?.id != null) Container(
          height: 55.0,
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Dropdown<String>(
            dropdownMenuItemList: _buildFieldDropdown(),
            onTapped: _unfocus,
            onChanged: _onChange,
            value: selectedField?.id
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _buildFieldDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    List<Field>? fields = widget.fields;
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
  
  void _onChange(String? value) {
    widget.onChange!(value as String);
  }
  
  void _unfocus() {
    widget.unfocus!(true);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        _showTitle(),
        _showFieldDropdown()
      ],
    );
  }
}