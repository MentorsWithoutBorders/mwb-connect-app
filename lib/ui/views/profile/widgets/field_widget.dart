import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';

class Field extends StatefulWidget {
  Field({@required this.user});

  final User user;

  @override
  State<StatefulWidget> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();  
  ProfileViewModel _profileProvider;

  void setField(String field) {
    widget.user.field = field;
    _profileProvider.setUserDetails(widget.user);
  }    

  Widget _showField(context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputBox(autofocus: false, label: 'Field', hint: 'Enter Field', text: widget.user?.field, inputChangedCallback: setField)
    );
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;    
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showField(context);
  }
}