import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class UpdateGoalDialog extends StatefulWidget {
  UpdateGoalDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _UpdateGoalDialogState();
}

class _UpdateGoalDialogState extends State<UpdateGoalDialog> with TickerProviderStateMixin {
  CommonViewModel _commonProvider;
  GoalsViewModel _goalProvider;
  final _formKey = GlobalKey<FormState>();
  String _goalText;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    _getFormHeight();
  }
  
  void _getFormHeight() async {
    RenderBox box = _formKey.currentContext.findRenderObject();
    _commonProvider.setDialogInputHeight(box.size.height);
  }  

  Widget _showUpdateGoalDialog(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showInput(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Center(
      child: Text(
        'goal_dialog.update_goal'.tr(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,  
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'goal_dialog.update_goal_placeholder'.tr(),
            hintStyle: TextStyle(
              color: AppColors.SILVER
            ),
            enabledBorder: UnderlineInputBorder(      
              borderSide: BorderSide(color: AppColors.ALLPORTS),   
            ),  
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.ALLPORTS),
            ), 
            errorStyle: TextStyle(
              color: Colors.orange
            )
          ),
          initialValue: _goalProvider.selectedGoal.text,
          validator: (value) {
            if (value.isEmpty) {
              return 'goal_dialog.update_goal_error'.tr();
            }
            return null;
          },
          onChanged: (value) {
            Future.delayed(const Duration(milliseconds: 10), () {        
              if (value.isNotEmpty) {      
                WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
                _formKey.currentState.validate();
              }
            });
          },
          onSaved: (value) => _goalText = value
        )
      )
    ); 
  }

  Widget _showButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            child: Container(
              padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
              child: Text('common.cancel'.tr(), style: TextStyle(color: Colors.grey))
            ),
            onTap: () {
              Navigator.pop(context);
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
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _updateGoal();
                Navigator.pop(context);
              }                    
            },
            child: Text('goal_dialog.update_goal'.tr(), style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }
  
  void _updateGoal() {
    Goal goal = _goalProvider.selectedGoal;
    goal.text = _goalText;
    DateTime now = DateTime.now();
    goal.dateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);      
    _goalProvider.updateGoal(goal, _goalProvider.selectedGoal.id);
  }

  @override
  Widget build(BuildContext context) {
    _commonProvider = Provider.of<CommonViewModel>(context);
    _goalProvider = Provider.of<GoalsViewModel>(context);

    return _showUpdateGoalDialog(context);
  }
}