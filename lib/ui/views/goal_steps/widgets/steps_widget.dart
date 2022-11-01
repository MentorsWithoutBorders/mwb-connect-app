import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/step_card_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/add_step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class Steps extends StatefulWidget {
  const Steps({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  GoalsViewModel? _goalsProvider;  
  StepsViewModel? _stepsProvider;  
  final Axis _scrollDirection = Axis.vertical;  
  final AutoScrollController _scrollController = AutoScrollController();
  bool _isRetrievingSteps = false;
  bool _stepsRetrieved = false;
  final GlobalKey _addStepKey = GlobalKey();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }  

  void _setShouldShowTutorialChevrons() {
    if (_addStepKey.currentContext != null) {
      RenderBox addStepBox = _addStepKey.currentContext?.findRenderObject() as RenderBox;
      final Offset position = addStepBox.localToGlobal(Offset.zero); 
      final double screenHeight = MediaQuery.of(context).size.height;
      if (screenHeight - position.dy < 80) {
        if (_stepsProvider?.shouldShowTutorialChevrons == false && _stepsProvider?.isTutorialPreviewsAnimationCompleted == true) {
          _stepsProvider?.setShouldShowTutorialChevrons(true);
        }
      } else {
        if (_stepsProvider?.shouldShowTutorialChevrons == true && _stepsProvider?.isTutorialPreviewsAnimationCompleted == true) {
          _stepsProvider?.setShouldShowTutorialChevrons(false);
        }
      }
    }
  }
  
  void _scrollToStep() {
    int previousPosition = _stepsProvider?.previousStepPosition as int;
    if (![-1,0].contains(previousPosition)) {
      _scrollController.scrollToIndex(previousPosition - 1, preferPosition: AutoScrollPosition.begin);
      _stepsProvider?.previousStepPosition = -1;
    }
  }
  
  Widget _showSteps() {
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
              itemCount: _stepsProvider?.steps.length,
              itemBuilder: (BuildContext buildContext, int index) =>
                AutoScrollTag(
                  key: ValueKey<int>(index),
                  controller: _scrollController,
                  index: index,
                  child: StepCard(step: _stepsProvider?.steps[index])
                )
            )
          ),
          _showAddStepButton()
        ]
      )
    ); 
  }

  Widget _showAddStepButton() {
    return Padding(
      key: _addStepKey,
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: AppColors.JAPANESE_LAUREL,
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
              widgetInside: AddStepDialog(steps: _stepsProvider?.steps)
            ),
          );
        }        
      )
    );
  }

  void _afterLayout(_) {
    _setShouldShowTutorialChevrons();
    _scrollToStep();
  }
  
  Widget _showContent() {
    if (_stepsRetrieved) {  
      WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
      return _showSteps();
    } else {
      return const Padding(
        padding: EdgeInsets.only(top: 50.0),
        child: Loader()
      );
    }
  }
  
  Future<void> _getSteps() async {
    if (!_isRetrievingSteps) { 
      _isRetrievingSteps = true; 
      await _stepsProvider?.getSteps(_goalsProvider?.selectedGoal?.id as String);
      setState(() {
        _stepsRetrieved = true;
      });
    }    
  }

  @override
  Widget build(BuildContext context) {
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context);    

    return FutureBuilder<void>(
      future: _getSteps(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return _showContent();
      }
    );    
  }
}
