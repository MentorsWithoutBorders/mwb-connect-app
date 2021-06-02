import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/step_card_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/add_step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class Steps extends StatefulWidget {
  const Steps({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  GoalsViewModel _goalsProvider;  
  StepsViewModel _goalStepsProvider;  
  final Axis _scrollDirection = Axis.vertical;  
  final AutoScrollController _scrollController = AutoScrollController();
  List<StepModel> _steps = [];
  final GlobalKey _addStepKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    _setSteps();
    _scrollToStep();
    _setShouldShowTutorialChevrons();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }  

  void _setShouldShowTutorialChevrons() {
    if (_addStepKey.currentContext != null) {
      RenderBox addStepBox = _addStepKey.currentContext.findRenderObject();
      final Offset position = addStepBox.localToGlobal(Offset.zero); 
      final double screenHeight = MediaQuery.of(context).size.height;
      if (screenHeight - position.dy < 80) {
        if (!_goalStepsProvider.shouldShowTutorialChevrons && _goalStepsProvider.isTutorialPreviewsAnimationCompleted) {
          _goalStepsProvider.setShouldShowTutorialChevrons(true);
        }
      } else {
        if (_goalStepsProvider.shouldShowTutorialChevrons && _goalStepsProvider.isTutorialPreviewsAnimationCompleted) {
          _goalStepsProvider.setShouldShowTutorialChevrons(false);
        }
      }
    }
  }

  void _setSteps() {
    _goalStepsProvider.steps = _steps;
  }  
  
  void _scrollToStep() {
    if (![-1,0].contains(_goalStepsProvider.previousStepIndex)) {
      _scrollController.scrollToIndex(_goalStepsProvider.previousStepIndex, preferPosition: AutoScrollPosition.begin);
      _goalStepsProvider.previousStepIndex = -1;
    }
  }
  
  Widget _showSteps() {
    return FutureBuilder<List<StepModel>>(
      future: _goalStepsProvider.getSteps(_goalsProvider.selectedGoal.id),
      builder: (BuildContext context, AsyncSnapshot<List<StepModel>> snapshot) {
        if (snapshot.hasData) {
          _steps = snapshot.data;
          _steps = _goalStepsProvider.sortSteps(_steps);               
          WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
          return Expanded(
            child: Column(
              children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 0.0),
                    scrollDirection: _scrollDirection,
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: _steps.length,
                    itemBuilder: (BuildContext buildContext, int index) =>
                      AutoScrollTag(
                        key: ValueKey<int>(index),
                        controller: _scrollController,
                        index: index,
                        child: StepCard(step: _steps[index])
                      )
                  )
                ),
                _showAddStepButton()
              ]
            )
          );
        } else {
          return const Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Loader()
          );
        }
      }
    );
  }

  Widget _showAddStepButton() {
    return Padding(
      key: _addStepKey,
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: AppColors.MONZA,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          elevation: 2.0,
          padding: const EdgeInsets.fromLTRB(50.0, 12.0, 50.0, 12.0)          
        ),
        child: Text('steps.add_step'.tr(), style: const TextStyle(color: Colors.white)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AnimatedDialog(
              widgetInside: AddStepDialog(steps: _steps),
              hasInput: true,
            ),
          );
        }        
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _goalStepsProvider = Provider.of<StepsViewModel>(context);

    return _showSteps();
  }
}
