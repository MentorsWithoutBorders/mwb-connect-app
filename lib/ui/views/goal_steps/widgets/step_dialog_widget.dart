import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/update_step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/add_sub_step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class StepDialog extends StatefulWidget {
  StepDialog({@required this.context});

  final BuildContext context;  

  @override
  State<StatefulWidget> createState() => _StepDialogState();
}

class _StepDialogState extends State<StepDialog> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();    
  GoalsViewModel _goalProvider;
  StepsViewModel _stepProvider;
  
  Widget _showStepDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 25.0),
      child: Wrap(
        children: <Widget>[
          Center(
            child: Text(
              _translator.getText('step_dialog.title'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Wrap(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    splashColor: AppColors.ALLPORTS,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => AnimatedDialog(
                          widgetInside: UpdateStepDialog(),
                          hasInput: true,
                        ),
                      );                      
                    },
                    child: Text(_translator.getText('step_dialog.update_step'), style: TextStyle(color: Colors.white)),
                    color: AppColors.PACIFIC_BLUE
                  )
                ),
                if (_stepProvider.selectedStep.level <=1) SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    splashColor: AppColors.ALLPORTS,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => AnimatedDialog(
                          widgetInside: AddSubStepDialog(),
                          hasInput: true,
                        ),
                      );                       
                    },
                    child: Text(_translator.getText('step_dialog.add_sub_step'), style: TextStyle(color: Colors.white)),
                    color: AppColors.PACIFIC_BLUE
                  )
                ),
                if (_stepProvider.selectedStep.index > 0) SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    splashColor: AppColors.ALLPORTS,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _moveStepUp();
                    },
                    child: Text(_translator.getText('step_dialog.move_step_up'), style: TextStyle(color: Colors.white)),
                    color: AppColors.PACIFIC_BLUE
                  )
                ),
                if (_stepProvider.selectedStep.index < _stepProvider.getCurrentIndex(steps: _stepProvider.steps, parentId: _stepProvider.selectedStep.parent)) SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    splashColor: AppColors.ALLPORTS,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _moveStepDown();                     
                    },
                    child: Text(_translator.getText('step_dialog.move_step_down'), style: TextStyle(color: Colors.white)),
                    color: AppColors.PACIFIC_BLUE
                  )
                ),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    splashColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => AnimatedDialog(
                          widgetInside: _showDeleteStepDialog(),
                          hasInput: false,
                        ),
                      );                      
                    },
                    child: Text(_translator.getText('step_dialog.delete_step'), style: TextStyle(color: Colors.white)),
                    color: AppColors.MONZA
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(                      
                        child: Text(_translator.getText('common.cancel'), style: TextStyle(color: Colors.grey))
                      )
                    ),
                    onTap: () {
                      Navigator.pop(widget.context);
                    },
                  ),
                )
              ]
            )
          )
        ]
      )
    );
  }

  _moveStepUp() {
    _stepProvider.moveStepUp(_goalProvider.selectedGoal.id, _stepProvider.steps, _stepProvider.selectedStep);
  }

  _moveStepDown() {
    _stepProvider.moveStepDown(_goalProvider.selectedGoal.id, _stepProvider.steps, _stepProvider.selectedStep);
  }  
  
  Widget _showDeleteStepDialog() {
    List<String> subSteps = _stepProvider.getSubSteps(_stepProvider.selectedStep.id);
    return Container(
      width: MediaQuery.of(widget.context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          Center(
            child: Text(
              subSteps.length > 0 ? 
                _translator.getText('step_dialog.delete_step_sub_steps_message') : 
                _translator.getText('step_dialog.delete_step_message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            )
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
            child: Text(
              _stepProvider.selectedStep.text,
              style: TextStyle(
                fontSize: 14,
              )
            )
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
                    child: Text(_translator.getText('common.cancel'), style: TextStyle(color: Colors.grey))
                  ),
                  onTap: () {
                    Navigator.pop(widget.context);
                  },
                ),
                RaisedButton(
                  padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0),
                  splashColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  onPressed: () {
                    _deleteStep(subSteps);
                  },
                  child: Text(_translator.getText('step_dialog.delete_step'), style: TextStyle(color: Colors.white)),
                  color: AppColors.MONZA
                )
              ]
            )
          )
        ]
      )
    );
  }

  _deleteStep(List<String> subSteps) {
    _stepProvider.deleteStep(goalId: _goalProvider.selectedGoal.id, id: _stepProvider.selectedStep.id);
    _stepProvider.updateIndexesAfterDeleteStep(_goalProvider.selectedGoal.id, _stepProvider.steps, _stepProvider.selectedStep);
    if (subSteps.length > 0) {
      subSteps.forEach((stepId) { 
        _stepProvider.deleteStep(goalId: _goalProvider.selectedGoal.id, id: stepId);
      });
    }
    Navigator.pop(widget.context);    
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;       
    _goalProvider = Provider.of<GoalsViewModel>(context);
    _stepProvider = Provider.of<StepsViewModel>(context);

    return _showStepDialog();
  }
}

