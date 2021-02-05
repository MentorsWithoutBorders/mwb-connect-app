import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class FieldDropdown extends StatefulWidget {
  FieldDropdown({
    @required this.fields,
    this.selectedField,
    this.onFieldTappedCallback
  });

  final List<Field> fields;
  final String selectedField;
  final Function onFieldTappedCallback;  

  @override
  State<StatefulWidget> createState() => _FieldDropdownState();
}

class _FieldDropdownState extends State<FieldDropdown> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  ProfileViewModel _profileProvider;
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

  @override
  void initState() {
    super.initState();
    _fieldDropdownList = _buildFieldDropdown(widget.fields);
    _setSelectedField();
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

  Widget _showFieldDropdown() {
    return Container(
      height: 55,
      padding: const EdgeInsets.only(bottom: 15),
      child: Dropdown(
        dropdownMenuItemList: _fieldDropdownList,
        onTapped: widget.onFieldTappedCallback,
        onChanged: _changeField,
        value: _field
      ),
    );
  }

  void _changeField(Field field) {
    setState(() {
      _field = field;
    });
    _profileProvider.setField(field.name);
  }  

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;     
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return Wrap(
      children: [
        Label(text: 'Field'),
        _showFieldDropdown()
      ],
    );
  }
}