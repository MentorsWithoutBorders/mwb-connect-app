import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';

class Name extends StatefulWidget {
  Name({@required this.user});

  final User user;

  @override
  State<StatefulWidget> createState() => _NameState();
}

class _NameState extends State<Name> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  ProfileViewModel _profileProvider;  

  Widget _showName(context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 15),
      child: InputBox(
        autofocus: false, 
        hint: 'Enter name', 
        text: widget.user?.name, 
        inputChangedCallback: _changeName
      )
    );
  }

  void _changeName(String name) {
    _profileProvider.setName(name);
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;  
    _profileProvider = Provider.of<ProfileViewModel>(context);      

    return Wrap(
      children: [
        Label(text: 'Name'),
        _showName(context)
      ],
    );
  }
}