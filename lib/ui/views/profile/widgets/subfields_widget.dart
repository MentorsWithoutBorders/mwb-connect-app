import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfield_dropdown_widget.dart';

class Subfields extends StatefulWidget {
  const Subfields({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _SubfieldsState();
}

class _SubfieldsState extends State<Subfields> {
  ProfileViewModel _profileProvider;    

  Widget _showSubfields() {
    final List<Widget> subfieldWidgets = [];
    final List<Subfield> userSubfields = _profileProvider.user.field.subfields;
    subfieldWidgets.add(Label(text: 'profile.subfields'.tr()));
    if (userSubfields != null) {
      for (int i = 0; i < userSubfields.length; i++) {
        final Widget subfield = SubfieldDropdown(index: i);
        subfieldWidgets.add(subfield);
      }
    }
    subfieldWidgets.add(_showAddSubfieldButton());
    return Wrap(children: subfieldWidgets);
  }

  Widget _showAddSubfieldButton() {
    return Center(
      child: ElevatedButton(
        key: const Key(AppKeys.addSubfieldBtn),
        style: ElevatedButton.styleFrom(
          elevation: 1.0,
          primary: AppColors.MONZA,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0)
        ), 
        child: Text('profile.add_subfield'.tr(), style: TextStyle(color: Colors.white)),
        onPressed: () {
          _addSubfield();
        }
      ),
    );
  }

  void _addSubfield() {
    _unfocus();
    _profileProvider.addSubfield();    
  }

  void _unfocus() {
    _profileProvider.shouldUnfocus = true;
  }
  
  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showSubfields();
  }
}