import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/bullet_point_widget.dart';

class ConditionsList extends StatelessWidget {
  final String? quizzes;
  final bool? shouldShowQuizzes;
  final bool? shouldShowStep;

  const ConditionsList({
    Key? key,
    @required this.quizzes,
    @required this.shouldShowQuizzes,
    @required this.shouldShowStep
  }): super(key: key);  
  
  Widget _showConditionsList(BuildContext context) {
    String oneNewStep = 'lesson_request.one_new_step'.tr();
    String addStep = 'lesson_request.add_step'.tr(args: [oneNewStep]);
    String firstPartAddStep = addStep.substring(0, addStep.indexOf(oneNewStep));
    String secondPartAddStep = addStep.substring(addStep.indexOf(oneNewStep) + oneNewStep.length);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Wrap(
        children: <Widget>[
          if (shouldShowQuizzes == true) Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 30.0,
                  child: BulletPoint()
                ),
                Expanded(
                  child: RichText(
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: AppColors.DOVE_GRAY,
                        height: 1.3
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'lesson_request.solve'.tr()
                        ),
                        TextSpan(
                          text: ' ' + quizzes! + ' ',
                          style: const TextStyle(
                            color: AppColors.TANGO
                          )
                        ),
                        TextSpan(
                          text: 'common.from'.tr() + ' ' + 'common.the'.tr() + ' '
                        ), 
                        TextSpan(
                          text: 'common.mental_process_goal_steps'.tr().toLowerCase()                   
                        ),
                        TextSpan(
                          text: ', '
                        ),
                        TextSpan(
                          text: 'common.relaxation_method'.tr().toLowerCase()                    
                        ),
                        TextSpan(
                          text: ' ' + 'common.and'.tr() + ' '
                        ),
                        TextSpan(
                          text: 'common.super_focus_method'.tr().toLowerCase()                    
                        ), 
                      ],
                    )
                  )
                )
              ],
            ),
          ),
          if (shouldShowStep == true) Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 30.0,
                  child: BulletPoint()
                ),
                Expanded(
                  child: RichText(
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13.0,
                        color: AppColors.DOVE_GRAY,
                        height: 1.3
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: firstPartAddStep
                        ),
                        TextSpan(
                          text: oneNewStep,
                          style: const TextStyle(
                            color: AppColors.TANGO
                          )
                        ),
                        TextSpan(
                          text: secondPartAddStep
                        )
                      ],
                    )
                  )
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showConditionsList(context);
  }
}