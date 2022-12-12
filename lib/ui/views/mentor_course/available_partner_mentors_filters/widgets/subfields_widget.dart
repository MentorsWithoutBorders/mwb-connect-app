import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_partner_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/available_partner_mentors_filters/widgets/subfield_dropdown_widget.dart';

class Subfields extends StatefulWidget {
  const Subfields({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _SubfieldsState();
}

class _SubfieldsState extends State<Subfields> {
  AvailablePartnerMentorsViewModel? _availablePartnerMentorsProvider;    

  Widget _showSubfields() {
    final List<Widget> subfieldWidgets = [];
    final List<Subfield>? filterSubfields = _availablePartnerMentorsProvider?.filterField.subfields;
    subfieldWidgets.add(Label(text: 'common.subfields'.tr()));
    if (filterSubfields != null) {
      for (int i = 0; i < filterSubfields.length; i++) {
        final Widget subfield = SubfieldDropdown(index: i);
        subfieldWidgets.add(subfield);
      }
    }
    subfieldWidgets.add(_showAddSubfieldButton());
    return Wrap(children: subfieldWidgets);
  }

  Widget _showAddSubfieldButton() {
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(top: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0)
          ), 
          child: Text('common.add_subfield'.tr(), style: TextStyle(color: Colors.white)),
          onPressed: () {
            _addSubfield();
          }
        ),
      ),
    );
  }

  void _addSubfield() {
    _unfocus();
    _availablePartnerMentorsProvider?.addSubfield();
  }

  void _unfocus() {
    _availablePartnerMentorsProvider?.shouldUnfocus = true;
  }
  
  @override
  Widget build(BuildContext context) {
    _availablePartnerMentorsProvider = Provider.of<AvailablePartnerMentorsViewModel>(context);

    return _showSubfields();
  }
}