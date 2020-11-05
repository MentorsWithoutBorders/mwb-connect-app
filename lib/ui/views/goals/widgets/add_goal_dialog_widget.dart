import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';

class AddGoalDialog extends StatefulWidget {
  AddGoalDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> with TickerProviderStateMixin {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();    
  CommonViewModel _commonProvider;
  GoalsViewModel _goalProvider;
  final _formKey = GlobalKey<FormState>();
  String _goalText;  
  bool _isAddingGoal = false;

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

  Widget _showAddGoalDialog(BuildContext context) {
    final loader = SpinKitThreeBounce(
      color: Colors.white,
      size: 18.0,
      controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1000)),
    );

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          Center(
            child: Text(
              _translator.getText('goals.add_new_goal'),
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
                  //contentPadding: EdgeInsets.only(bottom: -20.0),
                  hintText: _translator.getText('goals.add_goal_placeholder'),
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
                    return _translator.getText('goals.add_goal_error');
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
                  onPressed: () async {
                    if (_formKey.currentState.validate() && !_isAddingGoal) {
                      _formKey.currentState.save();
                      await _addGoal();
                      Navigator.pop(context);
                    } 
                  },
                  child: !_isAddingGoal ? Text(
                    _translator.getText('goals.add_goal'), 
                    style: TextStyle(color: Colors.white)
                  ) : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: loader,
                  ),
                  color: AppColors.MONZA
                )
              ]
            )
          )
        ]
      )
    );
  }
  
  _addGoal() async {
    setState(() {
      _isAddingGoal = true;
    });
    int index = _goalProvider.getCurrentIndex(_goalProvider.goals) + 1;
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);      
    Goal goal = Goal(text: _goalText, index: index, dateTime: dateTime);
    Goal addedGoal = await _goalProvider.addGoal(goal);
    _goalProvider.addGoalToList(addedGoal);
    _goalProvider.sortGoalList();
    _goalProvider.setWasGoalAdded(true);
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;      
    _commonProvider = Provider.of<CommonViewModel>(context);
    _goalProvider = Provider.of<GoalsViewModel>(context);

    return _showAddGoalDialog(context);
  }
}