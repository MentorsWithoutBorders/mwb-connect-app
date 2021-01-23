import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/editable_goal_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/tutorial_previews_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/steps_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class GoalStepsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoalStepsViewState();
}

class _GoalStepsViewState extends State<GoalStepsView> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();  

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
        child: Text(_translator.getText('goal_steps.title')),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;  

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
