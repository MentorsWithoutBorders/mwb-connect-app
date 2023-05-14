import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/skills_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class SubfieldItem extends StatefulWidget {
  const SubfieldItem({Key? key, @required this.subfield, @required this.mentorsNames})
    : super(key: key); 

  final Subfield? subfield;
  final String? mentorsNames;

  @override
  State<StatefulWidget> createState() => _SubfieldItemState();
}

class _SubfieldItemState extends State<SubfieldItem> {
  Widget _showSubfieldItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          _showBullet(),
          _showSubfield()
        ],
      ),
    );
  }

  Widget _showBullet() {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Container(
        width: 8.0,
        height: 8.0,
        margin: const EdgeInsets.only(right: 10.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.SILVER
        )
      ),
    );
  }

  Widget _showSubfield() {
    final String subfieldName = widget.subfield?.name as String;
    final bool hasSkills = widget.subfield?.skills != null && widget.subfield?.skills!.length as int > 0;

    return Expanded(
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.DOVE_GRAY,
            fontSize: 14.0,
          ),
          children: <TextSpan>[
            TextSpan(
              text: subfieldName,
              style: const TextStyle(
                color: AppColors.DOVE_GRAY
              )
            ),
            if (hasSkills) TextSpan(
              text: ' (',
              style: const TextStyle(
                fontFamily: 'RobotoItalic',
              )
            ),
            if (hasSkills) TextSpan(
              text: 'common.see_skills'.tr(),
              style: const TextStyle(
                color: Colors.blue,
                fontFamily: 'RobotoItalic',
                decoration: TextDecoration.underline
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: SkillsDialog(
                      mentorName: widget.mentorsNames,
                      subfieldName: subfieldName,
                      skills: widget.subfield?.skills
                    )
                  )
                );
              } 
            ),
            if (hasSkills) TextSpan(
              text: ')',
              style: const TextStyle(
                fontFamily: 'RobotoItalic',
              )
            )
          ]
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showSubfieldItem();
  }
}