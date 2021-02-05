import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class SubfieldDropdown extends StatefulWidget {
  SubfieldDropdown({
    @required this.subfields,
    this.selectedSubfields,
    this.index,
    this.onSubfieldTappedCallback
  });

  final List<Subfield> subfields;
  final List<String> selectedSubfields;
  final int index;
  final Function onSubfieldTappedCallback;  

  @override
  State<StatefulWidget> createState() => _SubfieldDropdownState();
}

class _SubfieldDropdownState extends State<SubfieldDropdown> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  ProfileViewModel _profileProvider;  
  Subfield _subfield;

  List<DropdownMenuItem<Subfield>> _buildSubfieldDropdown(List<Subfield> subfieldList) {
    List<DropdownMenuItem<Subfield>> items = List();
    for (Subfield subfield in _setSubfields(subfieldList)) {
      items.add(DropdownMenuItem(
        value: subfield,
        child: Text(subfield.name),
      ));
    }
    return items;
  }

  List<Subfield> _setSubfields(List<Subfield> subfieldList) {
    List<Subfield> subfields = List();
    if (subfieldList != null) {
      for (int i = 0; i < subfieldList.length; i++) {
        if (!widget.selectedSubfields.contains(subfieldList[i].name) || 
            subfieldList[i].name == widget.selectedSubfields[widget.index]) {
          subfields.add(subfieldList[i]);
        }
      }
    }
    return subfields;
  }

  void _setSelectedSubfield() {
    String selectedSubfield;
    if (isNotEmpty(widget.selectedSubfields[widget.index])) {
      selectedSubfield = widget.selectedSubfields[widget.index];
    } else {
      selectedSubfield = widget.subfields[0].name;
    }
    for (int i = 0; i < widget.subfields.length; i++) {
      if (widget.subfields[i].name == selectedSubfield) {
        setState(() {
          _subfield = widget.subfields[i];
        });
        break;
      }
    }
  }

  Widget _showSubfieldDropdown() {
    return Container(
      height: 50,
      padding: EdgeInsets.only(bottom: 10),
      child: Dropdown(
        dropdownMenuItemList: _buildSubfieldDropdown(widget.subfields),
        onTapped: widget.onSubfieldTappedCallback,
        onChanged: _changeSubfield,
        value: _subfield
      ),
    );
  }

  void _changeSubfield(Subfield subfield) {
    setState(() {
      _subfield = subfield;
    });
    _profileProvider.setSubfield(subfield.name, widget.index);
  }    

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;
    _profileProvider = Provider.of<ProfileViewModel>(context);
    _setSelectedSubfield();

    return _showSubfieldDropdown();
  }
}