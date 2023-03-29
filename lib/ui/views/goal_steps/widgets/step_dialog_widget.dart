import 'package:flutter/material.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/delete_step_dialog_widget.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/update_step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/add_sub_step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class StepDialog extends StatefulWidget {
  const StepDialog({Key? key, @required this.context})
    : super(key: key);  

  final BuildContext? context;  

  @override
  State<StatefulWidget> createState() => _StepDialogState();
}

class _StepDialogState extends State<StepDialog> {
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;
  
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
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showOptions() {
    int selectedStepLevel = _stepsProvider?.selectedStep?.level as int;
    int selectedStepIndex = _stepsProvider?.selectedStep?.index as int;
    int currentIndex = _stepsProvider?.getCurrentIndex(steps: _stepsProvider?.steps, parentId: _stepsProvider?.selectedStep?.parentId) as int;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Wrap(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ALLPORTS,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ),  
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const AnimatedDialog(
                    widgetInside: UpdateStepDialog()
                  ),
                );                      
              },
              child: Text('step_dialog.update_step'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          if (selectedStepLevel <= 1) SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ALLPORTS,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ), 
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const AnimatedDialog(
                    widgetInside: AddSubStepDialog()
                  ),
                );                       
              },
              child: Text('step_dialog.add_sub_step'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          if (selectedStepIndex > 0) SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ALLPORTS,
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
          if (selectedStepIndex < currentIndex) SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ALLPORTS,
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
                backgroundColor: AppColors.MONZA,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: DeleteStepDialog()
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
                Navigator.pop(widget.context!);
              },
            ),
          )
        ]
      )
    );
  }

  void _moveStepUp() {
    _stepsProvider?.moveStepUp(_goalsProvider?.selectedGoal?.id as String, _stepsProvider?.selectedStep as StepModel);
  }

  void _moveStepDown() {
    _stepsProvider?.moveStepDown(_goalsProvider?.selectedGoal?.id as String, _stepsProvider?.selectedStep as StepModel);
  }  
  
  @override
  Widget build(BuildContext context) {
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context);

    return _showStepDialog();
  }
}

