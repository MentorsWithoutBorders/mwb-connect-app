import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/others/support_request_view.dart';

class LessonsStopped extends StatefulWidget {
  const LessonsStopped({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _LessonsStoppedState();
}

class _LessonsStoppedState extends State<LessonsStopped> {
  Widget _showLessonsStoppedCard() {
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
                child: _showText()
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
          'lessons_stopped.title'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.TANGO,
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }    

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13.0,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'lessons_stopped.text'.tr() + ' ',             
            ),
            TextSpan(
              text: 'common.contact_support'.tr(),
              style: const TextStyle(
                decoration: TextDecoration.underline
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                _goToSupport();
              } 
            ),
            TextSpan(
              text: '.'
            )
          ]
        )
      ),
    );
  }
 
  void _goToSupport() {
    Navigator.push(context, MaterialPageRoute<SupportView>(builder: (_) => SupportView()));
  } 
  
  @override
  Widget build(BuildContext context) {
    return _showLessonsStoppedCard();
  }
}