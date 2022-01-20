import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';

class Name extends StatefulWidget {
  const Name({Key? key})
    : super(key: key);    

  @override
  State<StatefulWidget> createState() => _NameState();
}

class _NameState extends State<Name> {
  ProfileViewModel? _profileProvider;  

  Widget _showName() {
    final double paddingBottom = _profileProvider?.user?.isMentor == true ? 15.0 : 5.0;
    return Container(
      padding: EdgeInsets.only(bottom: paddingBottom),
      child: InputBox(
        key: const Key(AppKeys.nameField),
        autofocus: false, 
        hint: 'profile.name_placeholder'.tr(), 
        text: _profileProvider?.user?.name as String, 
        textCapitalization: TextCapitalization.words,
        inputChangedCallback: _changeName
      )
    );
  }

  void _changeName(String name) {
    _profileProvider?.setName(name);
  }

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);      

    return Wrap(
      children: [
        Label(text: 'profile.name'.tr()),
        _showName()
      ],
    );
  }
}