import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/goal_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog.dart';

class EditableGoal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditableGoalState();
}

class _EditableGoalState extends State<EditableGoal> {
  GoalsViewModel _goalProvider;
  bool _isVisible = false;

  void _animateElements() async {
    if (!_isVisible) { 
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _isVisible = true;
      });
    } 
  }

  Widget _showEditableGoal(BuildContext context) {
    _animateElements();
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(16.0, 90.0, 16.0, 0.0),
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 15.0, 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Colors.white
      ),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AnimatedDialog(
              widgetInside: GoalDialog(context: context),
              hasInput: false,
            ),
          );           
        },
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 500),
          textAlign: TextAlign.center,
          style: !_isVisible ?
            TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontWeight: FontWeight.bold
            ) : TextStyle(
              fontSize: 20.0, 
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          child: Text(
            _goalProvider.selectedGoal != null && _goalProvider.selectedGoal.text != null ? _goalProvider.selectedGoal.text : ""
          )
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _goalProvider = Provider.of<GoalsViewModel>(context);

    return _showEditableGoal(context);
  }
}
