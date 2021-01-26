import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class FieldDropdown extends StatefulWidget {
  FieldDropdown({@required this.fields, this.selectedField, this.onFieldChangedCallback});

  final List<Field> fields;
  final String selectedField;
  final Function(String) onFieldChangedCallback;  

  @override
  State<StatefulWidget> createState() => _FieldDropdownState();
}

class _FieldDropdownState extends State<FieldDropdown> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();  
  Field _field;

  List<DropdownMenuItem<Field>> _fieldDropdownList;
  List<DropdownMenuItem<Field>> _buildFieldDropdown(List fieldList) {
    List<DropdownMenuItem<Field>> items = List();
    for (Field field in fieldList) {
      items.add(DropdownMenuItem(
        value: field,
        child: Text(field.name),
      ));
    }
    return items;
  }

  _onChangeFieldDropdown(Field field) {
    widget.onFieldChangedCallback(field.name);
    setState(() {
      _field = field;
    });
  }

  @override
  void initState() {
    _fieldDropdownList = _buildFieldDropdown(widget.fields);
    _setSelectedField();
    super.initState();
  }

  void _setSelectedField() {
    String selectedField;
    if (isNotEmpty(widget.selectedField)) {
      selectedField = widget.selectedField;
    } else {
      selectedField = widget.fields[0].name;
    }
    for (int i = 0; i < widget.fields.length; i++) {
      if (widget.fields[i].name == selectedField) {
        _field = widget.fields[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 3.0, bottom: 8.0),
            child: const SizedBox(
              width: double.infinity,
              child: Text(
                'Field',
                style: TextStyle(
                  fontSize: 12.0
                ), 
              ),
            ),
          ),
          Container(
            child: Container(
              height: 40,
              child: Dropdown(
                dropdownMenuItemList: _fieldDropdownList,
                onChanged: _onChangeFieldDropdown,
                value: _field
              ),
            ),
          ),
        ],
      ),
    );
  }
}