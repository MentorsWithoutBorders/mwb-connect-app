import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/tutorials/tutorial_view.dart';

class ConditionsList extends StatelessWidget {
  const ConditionsList({Key key})
    : super(key: key); 
  
  Widget _showConditionsList(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 40.0,
                child: _showCircle()
              ),
              Expanded(
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
                        text: 'connect_with_mentor.solve_quiz'.tr(),             
                      ),
                      TextSpan(
                        text: 'common.mental_process_goal_steps'.tr().toLowerCase(),
                        style: const TextStyle(
                          decoration: TextDecoration.underline
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.push(context, MaterialPageRoute<TutorialView>(builder: (_) => TutorialView(type: 'mental_process_goal_steps')));
                        }                      
                      ),
                      TextSpan(
                        text: ', '
                      ),
                      TextSpan(
                        text: 'common.relaxation_method'.tr().toLowerCase(),
                        style: const TextStyle(
                          decoration: TextDecoration.underline
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.push(context, MaterialPageRoute<TutorialView>(builder: (_) => TutorialView(type: 'relaxation_method')));
                        }                      
                      ),
                      TextSpan(
                        text: ' ' + 'common.or'.tr() + ' '
                      ),
                      TextSpan(
                        text: 'common.super_focus_method'.tr().toLowerCase(),
                        style: const TextStyle(
                          decoration: TextDecoration.underline
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.push(context, MaterialPageRoute<TutorialView>(builder: (_) => TutorialView(type: 'super_focus_method')));
                        }                      
                      ), 
                    ],
                  )
                )
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 40.0,
                child: _showCircle()
              ),
              Expanded(
                child: Text(
                  'connect_with_mentor.add_step'.tr(),
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.DOVE_GRAY,
                    height: 1.2
                  )
                )
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _showCircle() {
    return Container(
      width: 8.0,
      height: 8.0,
      decoration: new BoxDecoration(
        color: AppColors.SILVER,
        shape: BoxShape.circle,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showConditionsList(context);
  }
}