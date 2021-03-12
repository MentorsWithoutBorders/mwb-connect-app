import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class AddGoalDialog extends StatefulWidget {
  AddGoalDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> with TickerProviderStateMixin {
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

  Widget _showAddGoalDialog() {
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
        'goals.add_new_goal'.tr(),
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
            //contentPadding: EdgeInsets.only(bottom: -20.0),
            hintText: 'goals.add_goal_placeholder'.tr(),
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
              return 'goals.add_goal_error'.tr();
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
    );
  }

  Widget _showButtons() {
    final loader = SpinKitThreeBounce(
      color: Colors.white,
      size: 18.0,
      controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1000)),
    );

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
            onPressed: () async {
              if (_formKey.currentState.validate() && !_isAddingGoal) {
                _formKey.currentState.save();
                await _addGoal();
                Navigator.pop(context);
              } 
            },
            child: !_isAddingGoal ? Text(
              'goals.add_goal'.tr(), 
              style: TextStyle(color: Colors.white)
            ) : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: loader,
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
    _commonProvider = Provider.of<CommonViewModel>(context);
    _goalProvider = Provider.of<GoalsViewModel>(context);

    return _showAddGoalDialog();
  }
}