import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';

class UpdateGoalDialog extends StatefulWidget {
  UpdateGoalDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _UpdateGoalDialogState();
}

class _UpdateGoalDialogState extends State<UpdateGoalDialog> with TickerProviderStateMixin {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();    
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
          Center(
            child: Text(
              _translator.getText('goal_dialog.update_goal'),
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
                  hintText: _translator.getText('goal_dialog.update_goal_placeholder'),
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
                    return _translator.getText('goal_dialog.update_goal_error');
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
                onSaved: (value) => _goalText = value
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
                      _updateGoal();
                      Navigator.pop(context);
                    }                    
                  },
                  child: Text(_translator.getText('goal_dialog.update_goal'), style: TextStyle(color: Colors.white)),
                  color: AppColors.MONZA
                )
              ]
            )
          )
        ]
      )
    );
  }
  
  _updateGoal() {
    Goal goal = _goalProvider.selectedGoal;
    goal.text = _goalText;
    DateTime now = DateTime.now();
    goal.dateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);      
    _goalProvider.updateGoal(goal, _goalProvider.selectedGoal.id);
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;      
    _commonProvider = Provider.of<CommonViewModel>(context);
    _goalProvider = Provider.of<GoalsViewModel>(context);

    return _showUpdateGoalDialog(context);
  }
}