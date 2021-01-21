import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/ui/widgets/input_box.dart';

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

  void setName(String name) {
    widget.user.name = name;
    _profileProvider.setUserDetails(widget.user);
  }    

  Widget _showName(context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputBox(autofocus: false, label: 'Name', hint: 'Enter name', text: widget.user?.name, inputChangedCallback: setName)
    );
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;    
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showName(context);
  }
}