import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class SubfieldDropdown extends StatefulWidget {
  SubfieldDropdown({
    this.index,
    this.onSubfieldTappedCallback
  });

  final int index;
  final Function onSubfieldTappedCallback;  

  @override
  State<StatefulWidget> createState() => _SubfieldDropdownState();
}

class _SubfieldDropdownState extends State<SubfieldDropdown> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  ProfileViewModel _profileProvider;  
  Subfield _selectedSubfield;

  @override
  void initState() {
    super.initState();
  }


  List<DropdownMenuItem<Subfield>> _buildSubfieldDropdown() {
    List<DropdownMenuItem<Subfield>> items = List();
    for (Subfield subfield in _profileProvider.getSubfields(widget.index)) {
      items.add(DropdownMenuItem(
        value: subfield,
        child: Text(subfield.name),
      ));
    }
    return items;
  }

  Widget _showSubfieldDropdown() {
    return Container(
      height: 50,
      padding: EdgeInsets.only(bottom: 10),
      child: Dropdown(
        dropdownMenuItemList: _buildSubfieldDropdown(),
        onTapped: widget.onSubfieldTappedCallback,
        onChanged: _changeSubfield,
        value: _selectedSubfield
      ),
    );
  }

  void _changeSubfield(Subfield subfield) {
    _setSelectedSubfield(subfield);
    _profileProvider.setSubfield(subfield.name, widget.index);
  }
  
  void _setSelectedSubfield(Subfield subfield) {
    setState(() {
      _selectedSubfield = subfield;
    });
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;
    _profileProvider = Provider.of<ProfileViewModel>(context);
    _setSelectedSubfield(_profileProvider.getSelectedSubfield(widget.index));

    return _showSubfieldDropdown();
  }
}