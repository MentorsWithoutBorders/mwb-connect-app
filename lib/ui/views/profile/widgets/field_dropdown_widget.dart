import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class FieldDropdown extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FieldDropdownState();
}

class _FieldDropdownState extends State<FieldDropdown> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  ProfileViewModel _profileProvider;
  Field _selectedField;

  List<DropdownMenuItem<Field>> _buildFieldDropdown() {
    List<DropdownMenuItem<Field>> items = List();
    for (Field field in _profileProvider.profile.fields) {
      items.add(DropdownMenuItem(
        value: field,
        child: Text(field.name),
      ));
    }
    return items;
  }

  Widget _showFieldDropdown() {
    return Container(
      height: 55,
      padding: const EdgeInsets.only(bottom: 15),
      child: Dropdown(
        dropdownMenuItemList: _buildFieldDropdown(),
        onTapped: _unfocus,
        onChanged: _changeField,
        value: _selectedField
      ),
    );
  }

  void _changeField(Field field) {
    _setSelectedField(field);
    _profileProvider.setField(field.name);
  }
  
  void _setSelectedField(Field field) {
    setState(() {
      _selectedField = field;
    });
  }

  void _unfocus() {
    _profileProvider.shouldUnfocus = true;
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;     
    _profileProvider = Provider.of<ProfileViewModel>(context);
    _setSelectedField(_profileProvider.getSelectedField());

    return Wrap(
      children: [
        Label(text: 'Field'),
        _showFieldDropdown()
      ],
    );
  }
}