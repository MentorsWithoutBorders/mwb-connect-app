import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';

class Name extends StatefulWidget {
  Name({@required this.user, this.onNameChangedCallback});

  final User user;
  final Function(String) onNameChangedCallback;  

  @override
  State<StatefulWidget> createState() => _NameState();
}

class _NameState extends State<Name> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  
  Widget _showLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0, bottom: 8.0),
      child: Text(
        'Name',
        style: TextStyle(
          fontSize: 12.0,
          color: AppColors.DOVE_GRAY
        ),
      )
    );
  }  

  Widget _showName(context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InputBox(
        autofocus: false, 
        hint: 'Enter name', 
        text: widget.user?.name, 
        inputChangedCallback: widget.onNameChangedCallback
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;    

    return Wrap(
      children: [
        _showLabel(),
        _showName(context)
      ],
    );
  }
}