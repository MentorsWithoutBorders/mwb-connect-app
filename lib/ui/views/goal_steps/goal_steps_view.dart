import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/editable_goal_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/tutorial_previews_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/steps_widget.dart';
import 'package:mwb_connect_app/ui/views/quizzes/quiz_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class GoalStepsView extends StatefulWidget {
  const GoalStepsView({Key? key})
    : super(key: key);
    
  @override
  State<StatefulWidget> createState() => _GoalStepsViewState();
}

class _GoalStepsViewState extends State<GoalStepsView> {
  QuizzesViewModel? _quizzesProvider;
  bool _isQuizDialogOpen = false;

  Widget _showGoalSteps(bool isHorizontal) {
    return Stack(
      children: <Widget>[
        BackgroundGradient(),
        Column(
          children: <Widget>[
            EditableGoal(),
            if (!isHorizontal) TutorialPreviews(),
            if (isHorizontal) SizedBox(height: 20.0),
            Steps()
          ]
        )
      ]
    );
  }

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'goal_steps.title'.tr(),
          textAlign: TextAlign.center
        )
      )
    );
  }

  Future<void> _showQuiz(_) async {
    int remainingQuizzes = _quizzesProvider!.calculateRemainingQuizzes();
    bool wasQuizDialogClosed = _quizzesProvider!.wasClosed;
    if (remainingQuizzes > 0) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted && !_isQuizDialogOpen && !wasQuizDialogClosed) {
        _isQuizDialogOpen = true;
        showDialog(
          context: context,
          builder: (_) => AnimatedDialog(
            widgetInside: QuizView()
          ),
        ).then((_) => _isQuizDialogOpen = false);
      }
    }    
  }

  @override
  Widget build(BuildContext context) {
    _quizzesProvider = Provider.of<QuizzesViewModel>(context);    
    WidgetsBinding.instance?.addPostFrameCallback(_showQuiz);

    return Scaffold(
      appBar: AppBar(
        title: _showTitle(),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: OrientationBuilder(
        builder: (context, orientation){
          if (orientation == Orientation.portrait) {
            return _showGoalSteps(false);
          } else {
            return _showGoalSteps(true);
          }
        }
      )
    );
  }
}
