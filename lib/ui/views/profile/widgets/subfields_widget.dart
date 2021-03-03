import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfield_dropdown_widget.dart';

class Subfields extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SubfieldsState();
}

class _SubfieldsState extends State<Subfields> {
  ProfileViewModel _profileProvider;    

  Widget _showSubfields() {
    List<Widget> subfieldWidgets = List();
    List<String> selectedSubfields = _profileProvider.profile.user.subfields;
    subfieldWidgets.add(Label(text: 'Subfields'));
    if (selectedSubfields != null) {
      for (int i = 0; i < selectedSubfields.length; i++) {
        Widget subfield = SubfieldDropdown(index: i);
        subfieldWidgets.add(subfield);
      }
    }
    subfieldWidgets.add(_showAddSubfieldButton());
    return Wrap(children: subfieldWidgets);
  }

  Widget _showAddSubfieldButton() {
    return Center(
      child: RaisedButton(
        key: Key(AppKeys.addSubfieldBtn),
        elevation: 1.0,
        padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
        splashColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        color: AppColors.MONZA,
        child: Text('Add subfield', style: TextStyle(color: Colors.white)),
        onPressed: () => _profileProvider.addSubfield()
      ),
    );
  } 

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showSubfields();
  }
}