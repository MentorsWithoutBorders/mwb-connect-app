import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class SubfieldDropdown extends StatefulWidget {
  SubfieldDropdown({@required this.index});

  final int index;

  @override
  State<StatefulWidget> createState() => _SubfieldDropdownState();
}

class _SubfieldDropdownState extends State<SubfieldDropdown> {
  ProfileViewModel _profileProvider;  
  Subfield _selectedSubfield;

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
      height: 50.0,
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Dropdown(
              dropdownMenuItemList: _buildSubfieldDropdown(),
              onTapped: _unfocus,
              onChanged: _changeSubfield,
              value: _selectedSubfield
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                child: Container(
                  width: 30.0,
                  height: 40.0,
                  child: Image.asset(
                    'assets/images/delete_icon.png'
                  ),
                ),
                onTap: () => _profileProvider.deleteSubfield(widget.index)                
              )
            ], 
          )
        ],
      )
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

  void _unfocus() {
    _profileProvider.shouldUnfocus = true;
  }  

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);
    _setSelectedSubfield(_profileProvider.getSelectedSubfield(widget.index));

    return _showSubfieldDropdown();
  }
}