import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/editable_goal_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/tutorial_previews_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/steps_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class GoalStepsView extends StatefulWidget {
  const GoalStepsView({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _GoalStepsViewState();
}

class _GoalStepsViewState extends State<GoalStepsView> {
  Widget _showGoalSteps() {
    return Stack(
      children: <Widget>[
        BackgroundGradient(),
        Column(
          children: <Widget>[
            EditableGoal(),
            TutorialPreviews(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showTitle(),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: _showGoalSteps()
    );
  }
}
