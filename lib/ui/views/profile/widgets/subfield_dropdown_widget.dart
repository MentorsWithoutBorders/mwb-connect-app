import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class SubfieldDropdown extends StatefulWidget {
  const SubfieldDropdown({Key key, @required this.index})
    : super(key: key); 

  final int index;

  @override
  State<StatefulWidget> createState() => _SubfieldDropdownState();
}

class _SubfieldDropdownState extends State<SubfieldDropdown> {
  ProfileViewModel _profileProvider;  
  Subfield _selectedSubfield;

  Widget _showSubfieldDropdown() {
    return Container(
      height: 50.0,
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Dropdown<Subfield>(
              key: Key(AppKeys.subfieldDropdown + widget.index.toString()),
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
                key: Key(AppKeys.deleteSubfieldBtn + widget.index.toString()),
                child: Container(
                  width: 30.0,
                  height: 40.0,
                  child: Image.asset(
                    'assets/images/delete_icon.png'
                  ),
                ),
                onTap: () {
                  _deleteSubfield();
                }                 
              )
            ], 
          )
        ],
      )
    );
  }

  void _deleteSubfield() {
    _unfocus();
    _profileProvider.deleteSubfield(widget.index);
  }

  List<DropdownMenuItem<Subfield>> _buildSubfieldDropdown() {
    final List<DropdownMenuItem<Subfield>> items = [];
    for (final Subfield subfield in _profileProvider.getSubfields(widget.index)) {
      items.add(DropdownMenuItem<Subfield>(
        value: subfield,
        child: Text(subfield.name),
      ));
    }
    return items;
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