import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/update_goal_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class GoalDialog extends StatefulWidget {
  GoalDialog({@required this.context});

  final BuildContext context;  

  @override
  State<StatefulWidget> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  GoalsViewModel _goalProvider;
  StepsViewModel _stepProvider;


  Widget _showGoalDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 25.0),
      child: Wrap(
        children: <Widget>[
          Center(
            child: Text(
              _translator.getText('goal_dialog.title'),
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
                          widgetInside: UpdateGoalDialog(),
                          hasInput: true,
                        ),
                      );                      
                    },
                    child: Text(_translator.getText('goal_dialog.update_goal'), style: TextStyle(color: Colors.white)),
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
                          widgetInside: _showDeleteGoalDialog(),
                          hasInput: false,
                        ),
                      );                      
                    },
                    child: Text(_translator.getText('goal_dialog.delete_goal'), style: TextStyle(color: Colors.white)),
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

  Widget _showDeleteGoalDialog() {
    return Container(
      width: MediaQuery.of(widget.context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          Center(
            child: Text(
              _stepProvider.steps.length > 0 ? 
                _translator.getText('goal_dialog.delete_goal_steps_message') :
                _translator.getText('goal_dialog.delete_goal_message'),
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
              _goalProvider.selectedGoal.text,
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
                    _deleteGoal();
                  },
                  child: Text(_translator.getText('goal_dialog.delete_goal'), style: TextStyle(color: Colors.white)),
                  color: AppColors.MONZA
                )
              ]
            )
          )
        ]
      )
    );
  }

  _deleteGoal() {
    _goalProvider.deleteGoal(_goalProvider.selectedGoal.id);
    _goalProvider.updateIndexesAfterDeleteGoal(_goalProvider.selectedGoal.id, _goalProvider.goals, _goalProvider.selectedGoal.index);
    Navigator.pop(widget.context);
    Navigator.pop(widget.context);
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;
    _goalProvider = Provider.of<GoalsViewModel>(context);
    _stepProvider = Provider.of<StepsViewModel>(context);

    return _showGoalDialog();
  }
}

