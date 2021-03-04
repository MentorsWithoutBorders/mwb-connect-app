import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';

class AddStepDialog extends StatefulWidget {
  AddStepDialog({Key key, this.steps})
    : super(key: key);  

  final List<StepModel> steps;

  @override
  State<StatefulWidget> createState() => _AddStepDialogState();
}

class _AddStepDialogState extends State<AddStepDialog> with TickerProviderStateMixin {
  CommonViewModel _commonProvider;
  GoalsViewModel _goalProvider;
  StepsViewModel _stepProvider;
  final _formKey = GlobalKey<FormState>();
  String _stepText;
  
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

  Widget _showAddStepDialog() {
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
        'steps.add_new_step'.tr(),
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
            hintText: 'steps.add_step_placeholder'.tr(),
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
          validator: (value) {
            if (value.isEmpty) {
              return 'steps.add_step_error'.tr();
            }
          },
          onChanged: (value) {
            Future.delayed(const Duration(milliseconds: 10), () {        
              if (value.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback(_afterLayout);             
                _formKey.currentState.validate();
              }
            });
          },
          onSaved: (value) => _stepText = value
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
          RaisedButton(
            padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0),
            splashColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                _addStep();
                Navigator.pop(context);
              } 
            },
            child: Text('steps.add_step'.tr(), style: TextStyle(color: Colors.white)),
            color: AppColors.MONZA
          )
        ]
      )
    ); 
  }
  
  void _addStep() async {
    int index = _stepProvider.getCurrentIndex(steps: widget.steps, parentId: null) + 1;
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);      
    StepModel step = StepModel(text: _stepText, level: 0, index: index, dateTime: dateTime);
    _stepProvider.setAddedStepIndex(widget.steps, step);
    _stepProvider.addStep(goalId: _goalProvider.selectedGoal.id, data: step);
  }

  @override
  Widget build(BuildContext context) {
    _commonProvider = Provider.of<CommonViewModel>(context);
    _goalProvider = Provider.of<GoalsViewModel>(context);
    _stepProvider = Provider.of<StepsViewModel>(context);

    return _showAddStepDialog();
  }
}