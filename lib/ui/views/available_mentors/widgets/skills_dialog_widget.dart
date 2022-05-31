import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';

class SkillsDialog extends StatefulWidget {
  const SkillsDialog({Key? key, @required this.mentorName, @required this.subfieldName, @required this.skills})
    : super(key: key);
    
  final String? mentorName;
  final String? subfieldName;
  final List<Skill>? skills;

  @override
  State<StatefulWidget> createState() => _SkillsDialogState();
}

class _SkillsDialogState extends State<SkillsDialog> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }      

  Widget _showSkillsDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showSkills(),
          _showCloseButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          'available_mentors.title_skills'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        'available_mentors.skills_text'.tr(args: [widget.mentorName as String, widget.subfieldName as String]),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 14.0,
          color: AppColors.DOVE_GRAY,
          height: 1.2
        )
      ),
    );
  }

  Widget _showSkills() {
    return Container(
      height: MediaQuery.of(context).size.width * 0.6,
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Scrollbar(
        controller: _scrollController,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.skills!.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: _showBullet()
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        widget.skills![index].name as String,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: AppColors.DOVE_GRAY
                        ),
                        overflow: TextOverflow.clip
                      )
                    )
                  )
                ] 
              )
            )
          )
        )
      )
    );
  }

  Widget _showBullet() {
    return Container(
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: AppColors.DOVE_GRAY,
        shape: BoxShape.circle,
      ),
    );
  }  

  Widget _showCloseButton() {
   return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.BERMUDA_GRAY,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0),
          ), 
          child: Text(
            'common.close'.tr(),
            style: const TextStyle(color: Colors.white)
          ),
          onPressed: () async {
            Navigator.pop(context);
          }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
   return _showSkillsDialog();
  }
}