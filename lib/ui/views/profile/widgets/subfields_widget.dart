import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfield_dropdown_widget.dart';

class Subfields extends StatefulWidget {
  Subfields({@required this.fields, this.selectedField, this.selectedSubfields});

  final List<Field> fields;
  final String selectedField;
  final List<String> selectedSubfields;

  @override
  State<StatefulWidget> createState() => _SubfieldsState();
}

class _SubfieldsState extends State<Subfields> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();

  Widget _showSubfields() {
    var subfieldWidgets = List<Widget>();
    subfieldWidgets.add(Label(text: 'Subfields'));
    for (int i = 0; i < widget.selectedSubfields.length; i++) {
      Widget subfield = SubfieldDropdown(
        subfields: widget.fields[_getSelectedFieldIndex(widget.fields, widget.selectedField)].subfields,
        selectedSubfields: widget.selectedSubfields,
        index: i
      );
      subfieldWidgets.add(subfield);
    }
    return Wrap(children: subfieldWidgets);
  }

  int _getSelectedFieldIndex(List<Field> fields, String selectedField) {
    int index = 0;
    for (int i = 0; i < fields.length; i++) {
      if (fields[i].name == selectedField) {
        index = i;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return _showSubfields();
  }
}