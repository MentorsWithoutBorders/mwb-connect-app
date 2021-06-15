import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/find_mentor_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/widgets/tag_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

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
                  text: 'common.your_profile'.tr(),
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
          padding: const EdgeInsets.only(bottom: 20.0),
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
            showDialog(
              context: context,
              builder: (_) => AnimatedDialog(
                widgetInside: FindMentorDialog(),
                hasInput: true,
              ),
            );
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