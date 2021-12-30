import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/ui/views/goals/goals_view.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/goal_steps_view.dart';

class TrainingCompleted extends StatefulWidget {
  const TrainingCompleted({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _TrainingCompletedState();
}

class _TrainingCompletedState extends State<TrainingCompleted> {
  ConnectWithMentorViewModel? _connectWithMentorProvider;
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;
  QuizzesViewModel? _quizzesProvider;

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
              if (!shouldShowReceiveCertificate() || isCertificateSent()) _showTitle(),
              if (!shouldShowReceiveCertificate() || isCertificateSent()) Container(
                padding: const EdgeInsets.only(left: 3.0),
                child: _showText()
              ),
              if (shouldShowReceiveCertificate() && !isCertificateSent()) _showReceiveCertificate(),              
            ],
          )
        ),
      ),
    );
  }

  bool shouldShowReceiveCertificate() => Utils.getTrainingWeekNumber() >= AppConstants.studentWeeksTraining && (_quizzesProvider!.quizzes.length == 0 || _quizzesProvider!.quizzes[_quizzesProvider!.quizzes.length - 1].number == AppConstants.studentQuizzes);

  bool isCertificateSent() => _connectWithMentorProvider?.studentCertificate?.isCertificateSent as bool;

  Widget _showTitle() {
    String week = Utils.getTrainingWeek();
    String title = isCertificateSent() ? 'connect_with_mentor.training_title'.tr() : 'training_completed.title'.tr(args: [week]);
    return Container(
      margin: const EdgeInsets.only(top: 3.0, bottom: 15.0),
      child: Center(
        child: Text(
          title,
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
    String text = isCertificateSent() ? 'training_completed.add_more_steps'.tr() : 'training_completed.text'.tr(args: [week]);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: text + ' ',             
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

  Widget _showReceiveCertificate() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: Text(
        'connect_with_mentor.congratulations_certificate'.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.EMERALD,
          fontWeight: FontWeight.bold
        )
      )
    );
  }   
 
  void _goToTraining() {
    if (_connectWithMentorProvider?.goal != null) {
      _goalsProvider?.setSelectedGoal(_connectWithMentorProvider?.goal);
      _goToGoalSteps();
    } else {
      Navigator.push(context, MaterialPageRoute<GoalsView>(builder: (_) => GoalsView())).then((value) => _goToGoalSteps());
    }
  }

  void _goToGoalSteps() {
    if (_goalsProvider?.selectedGoal != null) {
      _stepsProvider?.setShouldShowTutorialChevrons(false);
      _stepsProvider?.setIsTutorialPreviewsAnimationCompleted(false); 
      _connectWithMentorProvider?.setGoal(_goalsProvider?.selectedGoal);
      Navigator.push(context, MaterialPageRoute<GoalStepsView>(builder: (_) => GoalStepsView()));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context);
    _quizzesProvider = Provider.of<QuizzesViewModel>(context);

    return _showTrainingCompletedCard();
  }
}