import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfield_dropdown_widget.dart';

class Subfields extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SubfieldsState();
}

class _SubfieldsState extends State<Subfields> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  ProfileViewModel _profileProvider;    

  Widget _showSubfields() {
    var subfieldWidgets = List<Widget>();
    List<String> selectedSubfields = _profileProvider.profile.user.subfields;
    subfieldWidgets.add(Label(text: 'Subfields'));
    for (int i = 0; i < selectedSubfields.length; i++) {
      Widget subfield = SubfieldDropdown(index: i);
      subfieldWidgets.add(subfield);
    }
    return Wrap(children: subfieldWidgets);
  }

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showSubfields();
  }
}