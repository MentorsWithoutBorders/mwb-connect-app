import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/skills_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class SubfieldItem extends StatefulWidget {
  const SubfieldItem({Key? key, @required this.id, @required this.subfield, @required this.mentorName})
    : super(key: key); 

  final String? id;
  final Subfield? subfield;
  final String? mentorName;

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
    _availableMentorsProvider?.setErrorMessage('');
  }

  Widget _showSubfield() {
    final String subfieldName = widget.subfield?.name as String;
    final bool hasSkills = widget.subfield?.skills != null && widget.subfield?.skills!.length as int > 0;

    return Expanded(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.DOVE_GRAY
          ),
          children: <TextSpan>[
            TextSpan(
              text: subfieldName,
              style: const TextStyle(
                color: AppColors.DOVE_GRAY
              )
            ),
            if (hasSkills) TextSpan(
              text: ' ('
            ),
            if (hasSkills) TextSpan(
              text: 'available_mentors.see_skills'.tr(),
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 13.0,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: SkillsDialog(
                      mentorName: widget.mentorName,
                      subfieldName: subfieldName,
                      skills: widget.subfield?.skills
                    )
                  )
                );
              } 
            ),
            if (hasSkills) TextSpan(
              text: ')'
            )
          ]
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return _showSubfieldItem();
  }
}