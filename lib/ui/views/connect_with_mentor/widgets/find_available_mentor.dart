import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/widgets/tag_widget.dart';

class FindAvailableMentor extends StatefulWidget {
  const FindAvailableMentor({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _FindAvailableMentorState();
}

class _FindAvailableMentorState extends State<FindAvailableMentor> {
  ConnectWithMentorViewModel _connectWithMentorProvider;

  Widget _showFindAvailableMentorCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.only(bottom: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), 
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              _showTitle(),
              Container(
                padding: const EdgeInsets.only(left: 3.0),
                child: Wrap(
                  children: [
                    _showTopText(),
                    _showDivider(),
                    _showSkills(),
                    _showFindMentorButton()
                  ]
                )
              )
            ],
          )
        ),
      ),
    );
  }

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 3.0, bottom: 15.0),
      child: Text(
        'Find an available mentor',
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }   

  Widget _showTopText() {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.DOVE_GRAY,
                height: 1.2
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'connect_with_mentor.next_lesson'.tr(),             
                ),
                TextSpan(
                  text: 'connect_with_mentor.your_profile'.tr(),
                  style: const TextStyle(
                    decoration: TextDecoration.underline
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    Navigator.push(context, MaterialPageRoute<ProfileView>(builder: (_) => ProfileView()));
                  } 
                ),
                TextSpan(
                  text: '.'
                ),
              ],
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Text(
            'connect_with_mentor.interval_between_lessons'.tr(),
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.DOVE_GRAY,
              height: 1.2
            )
          ),
        )
      ],
    );
  }

  Widget _showDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: 15.0),
      color: AppColors.BOTTICELLI
    );
  }

  Widget _showSkills() {
    final List<Widget> skillWidgets = [];
    final List<String> skills = ['HTML', 'CSS', 'JavaScript', 'Python'];
    if (skills != null && skills.isNotEmpty) {
      for (int i = 0; i < skills.length; i++) {
        final Widget skill = Padding(
          padding: const EdgeInsets.only(right: 5.0, bottom: 7.0),
          child: Tag(
            key: Key(AppKeys.skillTag + i.toString()),
            color: AppColors.TAN_HIDE,
            text: skills[i],
            textKey: Key(AppKeys.skillText + i.toString()),
            deleteImg: 'assets/images/delete_circle_icon.png',
            deleteKey: Key(AppKeys.deleteSkillBtn + i.toString()),
            tagDeletedCallback: _deleteSkill
          ),
        );
        skillWidgets.add(skill);
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Text(
              'connect_with_mentor.skills_text'.tr(),
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.DOVE_GRAY,
                height: 1.2
              )
            ),
          ),
          if (skillWidgets.isNotEmpty) Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 4.0),
            decoration: const BoxDecoration(
              color: AppColors.LINEN,
              borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            child: Wrap(
              children: skillWidgets,
            )
          ),
        ],
      ),
    );
  }

  void _deleteSkill(String skill) {
    print('Delete skill');
  }  

  Widget _showFindMentorButton() {
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ), 
          child: Text('connect_with_mentor.find_mentor'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            print('Find mentor');
          }
        ),
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showFindAvailableMentorCard();
  }
}