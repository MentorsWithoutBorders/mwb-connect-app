import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';

class Name extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NameState();
}

class _NameState extends State<Name> {
  ProfileViewModel _profileProvider;  

  Widget _showName(context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 15),
      child: InputBox(
        key: Key('name'),
        autofocus: false, 
        hint: 'Enter name', 
        text: _profileProvider.profile.user?.name, 
        inputChangedCallback: _changeName
      )
    );
  }

  void _changeName(String name) {
    _profileProvider.setName(name);
  }

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);      

    return Wrap(
      children: [
        Label(text: 'Name'),
        _showName(context)
      ],
    );
  }
}