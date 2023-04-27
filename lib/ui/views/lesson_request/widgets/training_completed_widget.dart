import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/goals/goals_view.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/goal_steps_view.dart';

class TrainingCompleted extends StatefulWidget {
  const TrainingCompleted({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _TrainingCompletedState();
}

class _TrainingCompletedState extends State<TrainingCompleted> {
  LessonRequestViewModel? _lessonRequestProvider;
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;

  Widget _showTrainingCompletedCard() {
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
                padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                child: _showText()
              )
            ],
          )
        ),
      ),
    );
  }

  Widget _showTitle() {
    String week = Utils.getTrainingWeek();
    return Container(
      margin: const EdgeInsets.only(top: 3.0, bottom: 15.0),
      child: Center(
        child: Text(
          'training_completed.title'.tr(args: [week]),
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
    String week = Utils.getTrainingWeek();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13.0,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'training_completed.text'.tr(args: [week]) + ' ',             
            ),
            TextSpan(
              text: 'training_completed.use_this_link'.tr(),
              style: const TextStyle(
                decoration: TextDecoration.underline
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                _goToTraining();
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

  void _goToTraining() {
    if (_goalsProvider?.selectedGoal != null) {
      _goToGoalSteps();
    } else {
      _lessonRequestProvider?.addLogEntry('goal is null in training_completed_widget');
      Navigator.push(context, MaterialPageRoute<GoalsView>(builder: (_) => GoalsView())).then((value) => _goToGoalSteps());
    }
  }
  
  void _goToGoalSteps() {
    if (_goalsProvider?.selectedGoal != null) {
      _stepsProvider?.setShouldShowTutorialChevrons(false);
      _stepsProvider?.setIsTutorialPreviewsAnimationCompleted(false); 
      Navigator.push(context, MaterialPageRoute<GoalStepsView>(builder: (_) => GoalStepsView()));
    }
  }

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context); 

    return _showTrainingCompletedCard();
  }
}