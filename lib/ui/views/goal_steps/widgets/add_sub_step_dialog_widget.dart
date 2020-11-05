import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';

class AddSubStepDialog extends StatefulWidget {
  AddSubStepDialog({Key key, this.steps})
    : super(key: key);  

  final List<StepModel> steps;

  @override
  State<StatefulWidget> createState() => _AddSubStepDialogState();
}

class _AddSubStepDialogState extends State<AddSubStepDialog> with TickerProviderStateMixin {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();    
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

  Widget _showAddSubStepDialog(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          Center(
            child: Text(
              _translator.getText('step_dialog.add_sub_step'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                autofocus: true,  
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: _translator.getText('step_dialog.add_sub_step_placeholder'),
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
                    return _translator.getText('step_dialog.add_sub_step_error');
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
          ),
          Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                InkWell(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 12.0),
                    child: Text(_translator.getText('common.cancel'), style: TextStyle(color: Colors.grey))
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
                      _addSubStep();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(_translator.getText('step_dialog.add_sub_step'), style: TextStyle(color: Colors.white)),
                  color: AppColors.MONZA
                )
              ]
            )
          )
        ]
      )
    );
  }
  
  _addSubStep() {
    int level = _stepProvider.selectedStep.level + 1;
    int index = _stepProvider.getCurrentIndex(steps: _stepProvider.steps, parentId: _stepProvider.selectedStep.id) + 1;
    StepModel step = StepModel(text: _stepText, level: level, index: index, parent: _stepProvider.selectedStep.id);
    _stepProvider.setAddedStepIndex(_stepProvider.steps, step);
    _stepProvider.addStep(goalId: _goalProvider.selectedGoal.id, data: step);
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;      
    _commonProvider = Provider.of<CommonViewModel>(context);
    _goalProvider = Provider.of<GoalsViewModel>(context);
    _stepProvider = Provider.of<StepsViewModel>(context);

    return _showAddSubStepDialog(context);
  }
}