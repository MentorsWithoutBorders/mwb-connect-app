import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';

class SubfieldItem extends StatefulWidget {
  const SubfieldItem({Key? key, @required this.id, @required this.subfield})
    : super(key: key); 

  final String? id;
  final Subfield? subfield;

  @override
  State<StatefulWidget> createState() => _SubfieldItemState();
}

class _SubfieldItemState extends State<SubfieldItem> {
  AvailableMentorsViewModel? _availableMentorsProvider;

  Widget _showSubfieldItem() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            child: Row(
              children: [
                _showRadioButton(),
                _showSubfield()
              ],
            ),
            onTap: () {
              _setSubfieldOption(widget.id);
            }
          )
        )
      ]
    );
  }

  Widget _showRadioButton() {
    return SizedBox(
      width: 40.0,
      height: 30.0,
      child: Radio<String>(
        value: widget.id as String,
        groupValue: _availableMentorsProvider?.subfieldOptionId,
        onChanged: (String? value) {
          _setSubfieldOption(value);
        }
      )
    );
  }

  void _setSubfieldOption(String? value) {
    _availableMentorsProvider?.setSubfieldOptionId(value);
  }

  Widget _showSubfield() {
    final String subfieldName = widget.subfield?.name as String;
    return Expanded(
      child: Text(
        subfieldName,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return _showSubfieldItem();
  }
}