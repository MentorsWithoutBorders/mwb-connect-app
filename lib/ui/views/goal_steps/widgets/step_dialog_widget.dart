import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/update_step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/add_sub_step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class StepDialog extends StatefulWidget {
  const StepDialog({Key key, @required this.context})
    : super(key: key);  

  final BuildContext context;  

  @override
  State<StatefulWidget> createState() => _StepDialogState();
}

class _StepDialogState extends State<StepDialog> {
  GoalsViewModel _goalsProvider;
  StepsViewModel _stepsProvider;
  
  Widget _showStepDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 25.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showOptions()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Center(
      child: Text(
        'step_dialog.title'.tr(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showOptions() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Wrap(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.PACIFIC_BLUE,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ),  
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const AnimatedDialog(
                    widgetInside: UpdateStepDialog(),
                    hasInput: true,
                  ),
                );                      
              },
              child: Text('step_dialog.update_step'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          if (_stepsProvider.selectedStep.level <= 1) SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.PACIFIC_BLUE,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ), 
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const AnimatedDialog(
                    widgetInside: AddSubStepDialog(),
                    hasInput: true,
                  ),
                );                       
              },
              child: Text('step_dialog.add_sub_step'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          if (_stepsProvider.selectedStep.index > 0) SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.PACIFIC_BLUE,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ),
              onPressed: () {
                Navigator.pop(context);
                _moveStepUp();
              },
              child: Text('step_dialog.move_step_up'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          if (_stepsProvider.selectedStep.index < _stepsProvider.getCurrentIndex(steps: _stepsProvider.steps, parentId: _stepsProvider.selectedStep.parentId)) SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.PACIFIC_BLUE,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ),
              onPressed: () {
                Navigator.pop(context);
                _moveStepDown();                     
              },
              child: Text('step_dialog.move_step_down'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.MONZA,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
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
              child: Text('step_dialog.delete_step'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: InkWell(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(                      
                  child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
                )
              ),
              onTap: () {
                Navigator.pop(widget.context);
              },
            ),
          )
        ]
      )
    );
  }

  void _moveStepUp() {
    _stepsProvider.moveStepUp(_goalsProvider.selectedGoal.id, _stepsProvider.selectedStep);
  }

  void _moveStepDown() {
    _stepsProvider.moveStepDown(_goalsProvider.selectedGoal.id, _stepsProvider.selectedStep);
  }  
  
  Widget _showDeleteStepDialog() {
    final List<String> subSteps = _stepsProvider.getSubSteps(_stepsProvider.selectedStep.id);
    return Container(
      width: MediaQuery.of(widget.context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          Center(
            child: Text(
              subSteps.isNotEmpty ? 
                'step_dialog.delete_step_sub_steps_message'.tr() : 
                'step_dialog.delete_step_message'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
            child: Text(
              _stepsProvider.selectedStep.text,
              style: const TextStyle(
                fontSize: 14,
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
                    child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
                  ),
                  onTap: () {
                    Navigator.pop(widget.context);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: AppColors.MONZA,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0)
                  ), 
                  onPressed: () {
                    _deleteStep(subSteps);
                  },
                  child: Text('step_dialog.delete_step'.tr(), style: const TextStyle(color: Colors.white))
                )
              ]
            )
          )
        ]
      )
    );
  }

  void _deleteStep(List<String> subSteps) {
    _stepsProvider.deleteStep(_stepsProvider.selectedStep.id);
    Navigator.pop(widget.context);    
  }

  @override
  Widget build(BuildContext context) {
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context);

    return _showStepDialog();
  }
}

