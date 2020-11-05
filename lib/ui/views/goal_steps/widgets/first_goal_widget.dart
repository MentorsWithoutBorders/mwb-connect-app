import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/goal_steps_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient.dart';
import 'package:mwb_connect_app/ui/widgets/loader.dart';

class FirstGoal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FirstGoalState();
}

class _FirstGoalState extends State<FirstGoal> {
  GoalsViewModel _goalProvider;
  LocalizationDelegate localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  final _formKey = GlobalKey<FormState>();
  final _inputContainerOpacityDuration = 500;
  final _opacityDuration = 300;
  final _topAnimatedContainerDuration = 300;
  final _emptyAnimatedContainerDuration = 500;
  bool _isInputVisible = false;
  bool _isStartButtonVisible = true;
  bool _isAddingGoal = false;
  double _topAnimationHeight = 100;
  double _inputAnimationHeight = 80;
  String _goalText;  

  Widget _showFirstGoal() {
    _animateElements();     
    return Stack(
      children: <Widget>[           
        AnimatedOpacity(
          opacity: _isInputVisible ? 1.0 : 0.0,
          duration: Duration(milliseconds: _inputContainerOpacityDuration),
          child: Column(
            children: <Widget>[            
              AnimatedContainer(
                duration: Duration(milliseconds: _topAnimatedContainerDuration),
                width: 0.0,
                height: _topAnimationHeight
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    AnimatedOpacity(
                      opacity: _isStartButtonVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: _opacityDuration),
                      child: Container(
                        margin: const EdgeInsets.only(top: 20.0, left: 20.0),    
                        width: 400.0,
                        child: Text(
                          _translator.getText('goals.first_goal_label'),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white),
                        )
                      )
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: _emptyAnimatedContainerDuration),
                      width: 0.0,
                      height: _inputAnimationHeight
                    ),
                    AnimatedOpacity(
                      opacity: _isStartButtonVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: _opacityDuration),
                      child: Container(
                        margin: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                        child: TextFormField(
                          autofocus: true, 
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences, 
                          maxLines: null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(10.0),
                              ),
                            ),
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            hintText: _translator.getText('goals.first_goal_placeholder'),
                            filled: true,
                            fillColor: Colors.white,
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
                                _formKey.currentState.validate();
                              }
                            });
                          },                    
                          onSaved: (value) => _goalText = value
                        )
                      )
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: _emptyAnimatedContainerDuration),
                      width: 0.0,
                      height: _inputAnimationHeight
                    ),
                    AnimatedOpacity(
                      opacity: _isStartButtonVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: _opacityDuration),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: RaisedButton(
                          padding: const EdgeInsets.fromLTRB(60.0, 12.0, 60.0, 12.0),
                          splashColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();                            
                              await _addGoal();
                            }
                          },
                          child: Text(
                            _translator.getText('goals.first_goal_start'),
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 16
                            )
                          ),
                          color: AppColors.MONZA
                        )
                      )
                    )
                  ]
                )
              )
            ]
          )
        ),
      ]
    ); 
  }

  void _animateElements() async {
    if (!_isInputVisible) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _isInputVisible = true;
        _inputAnimationHeight = 0;
      });
    } 
  }  

  _addGoal() async {
    _transitionToGoalSteps();
    // Needed for setState to not be called when FirstGoal is not part of the view
    await Future.delayed(const Duration(milliseconds: 350));
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);    
    Goal goal = Goal(text: _goalText, index: 0, dateTime: dateTime);
    _isAddingGoal = true;
    Goal addedGoal = await _goalProvider.addGoal(goal);
    _isAddingGoal = false;
    _goalProvider.addGoalToList(addedGoal);
    _goalProvider.setSelectedGoal(addedGoal);
    _goToGoalStepsView();
  }
  
  _transitionToGoalSteps() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isStartButtonVisible = false;
      _topAnimationHeight = 50;
      _isInputVisible = false;
    });
  }

  _goToGoalStepsView() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => GoalStepsView()));    
  }
  
  @override
  Widget build(BuildContext context) {
    localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = localizationDelegate;       
    _goalProvider = Provider.of<GoalsViewModel>(context);

    if (!_isAddingGoal) {
      return _showFirstGoal();
    } else {
      return Stack(
        children: <Widget>[
          BackgroundGradient(),
          Loader()
        ]
      );
    }
  }
}
