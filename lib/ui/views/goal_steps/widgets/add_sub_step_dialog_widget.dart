import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goal_steps_view_model.dart';

class AddSubStepDialog extends StatefulWidget {
  const AddSubStepDialog({Key key, this.steps})
    : super(key: key);  

  final List<StepModel> steps;

  @override
  State<StatefulWidget> createState() => _AddSubStepDialogState();
}

class _AddSubStepDialogState extends State<AddSubStepDialog> with TickerProviderStateMixin {
  CommonViewModel _commonProvider;
  GoalsViewModel _goalsProvider;
  GoalStepsViewModel _goalStepsProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _stepText;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    _getFormHeight();
  }
  
  Future<void> _getFormHeight() async {
    RenderBox box = _formKey.currentContext.findRenderObject();
    _commonProvider.setDialogInputHeight(box.size.height);
  }  

  Widget _showAddSubStepDialog(BuildContext context) {
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
        'step_dialog.add_sub_step'.tr(),
        style: const TextStyle(
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
            hintText: 'step_dialog.add_sub_step_placeholder'.tr(),
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
          validator: (String value) {
            if (value.isEmpty) {
              return 'step_dialog.add_sub_step_error'.tr();
            }
            return null;
          },
          onChanged: (String value) {
            Future<void>.delayed(const Duration(milliseconds: 10), () {        
              if (value.isNotEmpty) { 
                WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
                _formKey.currentState.validate();
              }
            });
          },
          onSaved: (String value) => _stepText = value
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
              padding: const EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 12.0),
              child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
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
              padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0),
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _addSubStep();
                Navigator.pop(context);
              }
            },
            child: Text('step_dialog.add_sub_step'.tr(), style: const TextStyle(color: Colors.white))
          )
        ]
      )
    ); 
  }

  void _addSubStep() {
    final int level = _goalStepsProvider.selectedStep.level + 1;
    final int index = _goalStepsProvider.getCurrentIndex(steps: _goalStepsProvider.steps, parentId: _goalStepsProvider.selectedStep.id) + 1;
    final StepModel step = StepModel(text: _stepText, level: level, index: index, parentId: _goalStepsProvider.selectedStep.id);
    _goalStepsProvider.setAddedStepIndex(_goalStepsProvider.steps, step);
    _goalStepsProvider.addStep(_goalsProvider.selectedGoal.id, step);
  }

  @override
  Widget build(BuildContext context) {
    _commonProvider = Provider.of<CommonViewModel>(context);
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _goalStepsProvider = Provider.of<GoalStepsViewModel>(context);

    return _showAddSubStepDialog(context);
  }
}