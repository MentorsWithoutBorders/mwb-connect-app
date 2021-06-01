import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/goal_steps_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class FirstGoal extends StatefulWidget {
  const FirstGoal({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _FirstGoalState();
}

class _FirstGoalState extends State<FirstGoal> {
  GoalsViewModel _goalProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final int _inputContainerOpacityDuration = 500;
  final int _opacityDuration = 300;
  final int _topAnimatedContainerDuration = 300;
  final int _emptyAnimatedContainerDuration = 500;
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
                          'goals.first_goal_label'.tr(),
                          style: const TextStyle(
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
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            hintText: 'goals.first_goal_placeholder'.tr(),
                            filled: true,
                            fillColor: Colors.white,
                            errorStyle: const TextStyle(
                              color: Colors.orange
                            )
                          ),
                          validator: (String value) {
                            if (value.isEmpty) {
                              return 'goals.add_goal_error'.tr();
                            }
                            return null;
                          },
                          onChanged: (String value) {
                            Future<void>.delayed(const Duration(milliseconds: 10), () {        
                              if (value.isNotEmpty) {              
                                _formKey.currentState.validate();
                              }
                            });
                          },                    
                          onSaved: (String value) => _goalText = value
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: AppColors.MONZA,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)
                            ),
                            padding: const EdgeInsets.fromLTRB(60.0, 12.0, 60.0, 12.0),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();                            
                              await _addGoal();
                            }
                          },
                          child: Text(
                            'goals.first_goal_start'.tr(),
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 16
                            )
                          )
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

  Future<void> _animateElements() async {
    if (!_isInputVisible) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      setState(() {
        _isInputVisible = true;
        _inputAnimationHeight = 0;
      });
    } 
  }  

  Future<void> _addGoal() async {
    _transitionToGoalSteps();
    // Needed for setState to not be called when FirstGoal is not part of the view
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final Goal goal = Goal(text: _goalText);
    _isAddingGoal = true;
    final Goal addedGoal = await _goalProvider.addGoal(goal);
    _isAddingGoal = false;
    _goalProvider.addGoalToList(addedGoal);
    _goalProvider.setSelectedGoal(addedGoal);
    _goToGoalStepsView();
  }
  
  void _transitionToGoalSteps() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isStartButtonVisible = false;
      _topAnimationHeight = 50;
      _isInputVisible = false;
    });
  }

  void _goToGoalStepsView() {
    Navigator.push(context, MaterialPageRoute<GoalStepsView>(builder: (_) => GoalStepsView()));    
  }
  
  @override
  Widget build(BuildContext context) {
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
