import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/conditions_list_widget.dart';

class SolveQuizAddStep extends StatefulWidget {
  const SolveQuizAddStep({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _SolveQuizAddStepState();
}

class _SolveQuizAddStepState extends State<SolveQuizAddStep> {
  ConnectWithMentorViewModel? _connectWithMentorProvider;
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;
  QuizzesViewModel? _quizzesProvider;

  Widget _showSolveQuizAddStepCard() {
    String? quizzes = _quizzesProvider?.getRemainingQuizzesText();
    bool? shouldShowQuizzes = _quizzesProvider?.getShouldShowQuizzes();
    bool? shouldShowStep = _stepsProvider?.getShouldShowAddStep();

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
                child: Wrap(
                  children: [
                    _showTopText(),
                    ConditionsList(quizzes: quizzes, shouldShowQuizzes: shouldShowQuizzes, shouldShowStep: shouldShowStep),
                    _showNextDeadline(),
                    _showGoButton()
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
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Center(
        child: Text(
          'connect_with_mentor.training_title'.tr(),
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

  Widget _showTopText() {
    final DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');
    String certificateDate = dateFormat.format(_connectWithMentorProvider?.getCertificateDate() as DateTime);
    String text = 'connect_with_mentor.conditions_certificate'.tr(args: [certificateDate]);
    String and = 'common.and'.tr();
    String firstPart = text.substring(0, text.indexOf(and));
    String secondPart = text.substring(text.indexOf(and) + and.length, text.length);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.DOVE_GRAY,
            height: 1.3
          ),
          children: <TextSpan>[
            TextSpan(
              text: firstPart,             
            ),
            TextSpan(
              text: and,
              style: const TextStyle(
                fontStyle: FontStyle.italic
              )
            ),
            TextSpan(
              text: secondPart
            )
          ]
        )
      )
    );
  }
  
  Widget _showNextDeadline() {
    final DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');
    String deadline = dateFormat.format(Utils.getNextDeadline() as DateTime);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.DOVE_GRAY,
            height: 1.3
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'common.next_deadline'.tr() + ' ',
            ),
            TextSpan(
              text: deadline,
              style: TextStyle(
                color: AppColors.TANGO,
                fontWeight: FontWeight.bold
              )
            )
          ]
        )
      )
    );
  }

  Widget _showGoButton() {
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
            padding: const EdgeInsets.fromLTRB(50.0, 3.0, 50.0, 3.0),
          ), 
          child: Text('common.go'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            _goToGoal();
          }
        ),
      ),
    );
  }

  void _goToGoal() {
    _quizzesProvider!.wasClosed = false;
    if (_connectWithMentorProvider?.goal != null) {
      _goToGoalSteps();
    } else {
      _connectWithMentorProvider?.addLogEntry('goal is null in solve_quiz_add_step_widget');
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

    return _showSolveQuizAddStepCard();
  }
}