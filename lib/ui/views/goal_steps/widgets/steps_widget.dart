import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/step_card_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/add_step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog.dart';

class Steps extends StatefulWidget {
  Steps({Key key}): super(key: key);

  @override
  State<StatefulWidget> createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();  
  GoalsViewModel _goalProvider;  
  StepsViewModel _stepProvider;  
  final _scrollDirection = Axis.vertical;  
  AutoScrollController _scrollController = AutoScrollController();
  List<StepModel> _steps = List();
  GlobalKey _addStepKey = GlobalKey();

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
    super.dispose();
    _scrollController.dispose();
  }  

  void _setShouldShowTutorialChevrons() async {
    if (_addStepKey.currentContext != null) {
      RenderBox addStepBox = _addStepKey.currentContext.findRenderObject();
      Offset position = addStepBox.localToGlobal(Offset.zero); 
      double screenHeight = MediaQuery.of(context).size.height;
      if (screenHeight - position.dy < 80) {
        if (!_goalProvider.shouldShowTutorialChevrons && _goalProvider.isTutorialPreviewsAnimationCompleted) {
          _goalProvider.setShouldShowTutorialChevrons(true);
        }
      } else {
        if (_goalProvider.shouldShowTutorialChevrons && _goalProvider.isTutorialPreviewsAnimationCompleted) {
          _goalProvider.setShouldShowTutorialChevrons(false);
        }
      }
    }
  }

  void _setSteps() {
    _stepProvider.steps = _steps;
  }  
  
  void _scrollToStep() async {
    if (![-1,0].contains(_stepProvider.previousStepIndex)) {
      _scrollController.scrollToIndex(_stepProvider.previousStepIndex, preferPosition: AutoScrollPosition.begin);
      _stepProvider.previousStepIndex = -1;
    }
  }
  
  Widget _showSteps() {
    return StreamBuilder(
      stream: _stepProvider.fetchStepsAsStream(goalId: _goalProvider.selectedGoal.id),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          _steps = snapshot.data.documents
              .map((doc) => StepModel.fromMap(doc.data, doc.documentID))
              .toList();

          _steps = _stepProvider.sortSteps(_steps);               

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
                    itemBuilder: (buildContext, index) =>
                      AutoScrollTag(
                        key: ValueKey(index),
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
          return Padding(
            padding: const EdgeInsets.only(top: 50.0),
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
      child: RaisedButton(
        elevation: 2.0,
        padding: const EdgeInsets.fromLTRB(50.0, 12.0, 50.0, 12.0),
        splashColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        color: AppColors.MONZA,
        child: Text(_translator.getText('steps.add_step'), style: TextStyle(color: Colors.white)),
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
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;    
    _goalProvider = Provider.of<GoalsViewModel>(context);
    _stepProvider = Provider.of<StepsViewModel>(context);

    return _showSteps();
  }
}
