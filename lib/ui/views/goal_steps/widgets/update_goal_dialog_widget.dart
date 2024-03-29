import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class UpdateGoalDialog extends StatefulWidget {
  const UpdateGoalDialog({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _UpdateGoalDialogState();
}

class _UpdateGoalDialogState extends State<UpdateGoalDialog> with TickerProviderStateMixin {
  CommonViewModel? _commonProvider;
  GoalsViewModel? _goalsProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _goalText;
  bool _isUpdatingGoal = false;  
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    _getFormHeight();
  }
  
  void _getFormHeight() {
    RenderBox box = _formKey.currentContext?.findRenderObject() as RenderBox;
    _commonProvider?.setDialogInputHeight(box.size.height);
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
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18.0,
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
            hintStyle: const TextStyle(
              color: AppColors.SILVER
            ),
            enabledBorder: const UnderlineInputBorder(      
              borderSide: BorderSide(color: AppColors.ALLPORTS),   
            ),  
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.ALLPORTS),
            ), 
            errorStyle: const TextStyle(
              color: Colors.orange
            )
          ),
          initialValue: _goalsProvider?.selectedGoal?.text,
          validator: (String? value) {
            if (value?.isEmpty == true) {
              return 'goal_dialog.update_goal_error'.tr();
            }
            return null;
          },
          onChanged: (String value) {
            Future<void>.delayed(const Duration(milliseconds: 10), () {        
              if (value.isNotEmpty) {      
                WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
                _formKey.currentState?.validate();
              }
            });
          },
          onSaved: (String? value) => _goalText = value
        )
      )
    ); 
  }

  Widget _showButtons() {
    return Padding(
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
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.JAPANESE_LAUREL,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0)
            ),  
            onPressed: () async {
              if (_formKey.currentState?.validate() == true && !_isUpdatingGoal) {
                _formKey.currentState?.save();
                await _updateGoal();
                Navigator.pop(context);
              }                    
            },
            child: !_isUpdatingGoal ? Text(
              'goal_dialog.update_goal'.tr(), 
              style: const TextStyle(color: Colors.white)
            ) : SizedBox(
              width: 75.0,
              height: 16.0,
              child: ButtonLoader(),
            ) 
          )
        ]
      )
    );
  }
  
  Future<void> _updateGoal() async {
    setState(() {
      _isUpdatingGoal = true;
    });      
    final Goal goal = _goalsProvider?.selectedGoal as Goal;
    goal.text = _goalText;
    await _goalsProvider?.updateGoal(goal, _goalsProvider?.selectedGoal?.id as String);
  }

  @override
  Widget build(BuildContext context) {
    _commonProvider = Provider.of<CommonViewModel>(context);
    _goalsProvider = Provider.of<GoalsViewModel>(context);

    return _showUpdateGoalDialog(context);
  }
}