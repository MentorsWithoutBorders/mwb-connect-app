import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/goal_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class EditableGoal extends StatefulWidget {
  const EditableGoal({Key key})
    : super(key: key);  
  
  @override
  State<StatefulWidget> createState() => _EditableGoalState();
}

class _EditableGoalState extends State<EditableGoal> {
  GoalsViewModel _goalsProvider;
  bool _isVisible = false;

  Future<void> _animateElements() async {
    if (!_isVisible) { 
      await Future<void>.delayed(const Duration(milliseconds: 100));
      setState(() {
        _isVisible = true;
      });
    } 
  }

  Widget _showEditableGoal(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final Goal selectedGoal = _goalsProvider.selectedGoal;
    _animateElements();
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.fromLTRB(16.0, statusBarHeight, 16.0, 0.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        color: Colors.white
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => AnimatedDialog(
              widgetInside: GoalDialog(context: context)
            ),
          );           
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 12.0, 15.0, 12.0),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            textAlign: TextAlign.center,
            style: !_isVisible ?
              const TextStyle(
                fontSize: 20.0,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ) : const TextStyle(
                fontSize: 20.0, 
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
            child: Text(
              selectedGoal != null && selectedGoal.text != null ? selectedGoal.text : ''
            )
          ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _goalsProvider = Provider.of<GoalsViewModel>(context);

    return _showEditableGoal(context);
  }
}
