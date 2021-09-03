import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/update_goal_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class GoalDialog extends StatefulWidget {
  const GoalDialog({Key? key, @required this.context})
    : super(key: key);  

  final BuildContext? context;  

  @override
  State<StatefulWidget> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;

  Widget _showGoalDialog() {
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
        'goal_dialog.title'.tr(),
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
                    widgetInside: UpdateGoalDialog()
                  ),
                ); 
              },
              child: Text('goal_dialog.update_goal'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       primary: AppColors.MONZA,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(20.0)
          //       )
          //     ),
          //     onPressed: () {
          //       Navigator.pop(context);
          //       showDialog(
          //         context: context,
          //         builder: (_) => AnimatedDialog(
          //           widgetInside: _showDeleteGoalDialog()
          //         ),
          //       );                      
          //     },
          //     child: Text('goal_dialog.delete_goal'.tr(), style: const TextStyle(color: Colors.white))
          //   )
          // ),
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

  Widget _showDeleteGoalDialog() {
    return Container(
      width: MediaQuery.of(widget.context!).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          Center(
            child: Text(
              _stepsProvider?.steps?.isNotEmpty == true ? 
                'goal_dialog.delete_goal_steps_message'.tr() :
                'goal_dialog.delete_goal_message'.tr(),
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
              _goalsProvider?.selectedGoal?.text as String,
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
                    Navigator.pop(widget.context!);
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
                    _deleteGoal();
                  },
                  child: Text('goal_dialog.delete_goal'.tr(), style: const TextStyle(color: Colors.white))
                )
              ]
            )
          )
        ]
      )
    );
  }

  void _deleteGoal() {
    _goalsProvider?.deleteGoal(_goalsProvider?.selectedGoal?.id as String);
    Navigator.pop(widget.context!);
    Navigator.pop(widget.context!);
  }

  @override
  Widget build(BuildContext context) {
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context);

    return _showGoalDialog();
  }
}

