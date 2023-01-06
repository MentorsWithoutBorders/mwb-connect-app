import 'package:flutter/material.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class SubfieldDropdown extends StatelessWidget {
  const SubfieldDropdown({Key? key, this.subfields, required this.selectedSubfieldId, this.onSelect})
    : super(key: key);
    
  final List<Subfield>? subfields;
  final String? selectedSubfieldId;
  final Function(String?)? onSelect;

  Widget _showSubfieldDropdown() {
    return Container(
      height: 42.0,
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Dropdown<String>(
        dropdownMenuItemList: _buildSubfieldDropdown(),
        onChanged: onSelect,
        value: selectedSubfieldId
      )
    );
  }

  List<DropdownMenuItem<String>> _buildSubfieldDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    if (subfields != null) {
      for (final Subfield subfield in subfields!) {
        items.add(DropdownMenuItem<String>(
          value: subfield.id,
          child: Text(subfield.name as String),
        ));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return _showSubfieldDropdown();
  }
}