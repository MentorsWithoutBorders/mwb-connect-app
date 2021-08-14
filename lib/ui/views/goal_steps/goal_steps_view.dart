import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/editable_goal_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/tutorial_previews_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/steps_widget.dart';
import 'package:mwb_connect_app/ui/views/quizzes/quiz_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class GoalStepsView extends StatefulWidget {
  const GoalStepsView({Key key, this.quizNumber})
    : super(key: key);
    
  final int quizNumber;

  @override
  State<StatefulWidget> createState() => _GoalStepsViewState();
}

class _GoalStepsViewState extends State<GoalStepsView> {

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
        child: Text('goal_steps.title'.tr()),
      )
    );
  }

  Future<void> _showQuiz(_) async {
    if (widget.quizNumber != 0) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      showDialog(
        context: context,
        builder: (_) => AnimatedDialog(
          widgetInside: QuizView(quizNumber: widget.quizNumber)
        ),
      );
    }    
  }  

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_showQuiz);

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
          }else{
            return _showGoalSteps(true);
          }
        }
      )
    );
  }
}
