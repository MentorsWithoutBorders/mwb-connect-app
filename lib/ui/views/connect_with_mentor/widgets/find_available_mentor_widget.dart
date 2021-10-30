import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class FindAvailableMentor extends StatefulWidget {
  const FindAvailableMentor({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _FindAvailableMentorState();
}

class _FindAvailableMentorState extends State<FindAvailableMentor> with TickerProviderStateMixin {
  ConnectWithMentorViewModel? _connectWithMentorProvider;
  bool _isSendingLessonRequest = false;

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
      margin: const EdgeInsets.only(top: 3.0, bottom: 15.0),
      child: Center(
        child: Text(
          'connect_with_mentor.find_available_mentor'.tr(),
          style: const TextStyle(
            color: AppColors.TANGO,
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          )
        ),
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
                fontSize: 12.0,
                color: AppColors.DOVE_GRAY,
                height: 1.4
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
                )
              ]
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            'connect_with_mentor.interval_between_lessons'.tr(),
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 12.0,
              color: AppColors.DOVE_GRAY,
              height: 1.4
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
            primary: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ),
          child: !_isSendingLessonRequest ? Text(
            'connect_with_mentor.find_mentor'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 75.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _sendLessonRequest();
          }
        ),
      ),
    );
  }
  
  Future<void> _sendLessonRequest() async {  
    _setIsSendingLessonRequest(true);
    await _connectWithMentorProvider?.sendLessonRequest();
    _setIsSendingLessonRequest(false);
  }

  void _setIsSendingLessonRequest(bool isSending) {
    setState(() {
      _isSendingLessonRequest = isSending;
    });  
  }

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showFindAvailableMentorCard();
  }
}