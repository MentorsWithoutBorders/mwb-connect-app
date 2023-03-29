import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/first_goal_widget.dart';
import 'package:mwb_connect_app/ui/views/goals/widgets/goal_card_widget.dart';
import 'package:mwb_connect_app/ui/views/goals/widgets/add_goal_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({Key? key, this.logoutCallback})
    : super(key: key);  

  final VoidCallback? logoutCallback;

  @override
  State<StatefulWidget> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> with WidgetsBindingObserver {
  GoalsViewModel? _goalsProvider;
  final Axis _scrollDirection = Axis.vertical;  
  final AutoScrollController _scrollController = AutoScrollController();  
  final int _opacityDuration = 300;
  bool _isRetrievingGoals = false;
  bool _goalsRetrieved = false;
  bool _shouldShowGoals = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  void _afterLayout(_) {
    if (_goalsProvider?.wasGoalAdded == true) {
      _scrollToLastGoal();
      _goalsProvider?.setWasGoalAdded(false);
    }
  }

  void _scrollToLastGoal() {
    _scrollController.scrollToIndex(_goalsProvider?.goals.length as int);
  }
  
  Widget _showGoals() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return AnimatedOpacity(
      opacity: _shouldShowGoals ? 1.0 : 0.0,
      duration: Duration(milliseconds: _opacityDuration),
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight + 50.0),
        child: Column(
          children: <Widget>[
            Flexible(
              fit: FlexFit.loose,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 0.0),
                scrollDirection: _scrollDirection,
                controller: _scrollController,                
                shrinkWrap: true,
                itemCount: _goalsProvider?.goals.length,
                itemBuilder: (BuildContext buildContext, int index) =>
                  AutoScrollTag(
                    key: ValueKey<int>(index),
                    controller: _scrollController,
                    index: index,
                    child: GoalCard(goal: _goalsProvider?.goals[index])
                  )
              ),
            ),
            if (_goalsProvider?.goals != null && _goalsProvider?.goals.isNotEmpty == true) _showAddGoalButton()
          ]
        ),
      )
    );
  }

  Widget _showAddGoalButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.JAPANESE_LAUREL,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          elevation: 2.0,
          padding: const EdgeInsets.fromLTRB(50.0, 12.0, 50.0, 12.0)
        ),
        child: Text(
          'goals.add_goal'.tr(), 
          style: const TextStyle(
            color: Colors.white
          )
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AnimatedDialog(
              widgetInside: const AddGoalDialog()
            ),
          );
        },        
      )
    );
  }

  Widget _showTitle() {
    Widget title;
    if (_goalsProvider?.goals == null) {
      title = const Text('');
    } else {
      if (_goalsProvider?.goals.isNotEmpty == true) {
        title = Text(
          'goals.my_goals'.tr(),
          textAlign: TextAlign.center
        );
      } else {
        title = Text(
          'goals.first_goal'.tr(),
          textAlign: TextAlign.center
        );
      } 
    }

    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: title
      )
    );
  }

  Future<void> _getGoals() async {
    if (!_isRetrievingGoals) { 
      _isRetrievingGoals = true; 
      await _goalsProvider?.getGoals();
      setState(() {
        _goalsRetrieved = true;
      });
    } 
  }
  
  Widget _showContent() {
    // if (_goalsRetrieved) {
    //   if (_goalsProvider?.goals.isNotEmpty == true) {
    //     // For opacity animation
    //     Future<void>.delayed(const Duration(milliseconds: 300), () {
    //       if (mounted && !_shouldShowGoals) {
    //         setState(() {
    //           _shouldShowGoals = true;
    //         });
    //       }
    //     });
    //     WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    //     return _showGoals();
    //   } else {
    //     return FirstGoal();
    //   }
    // } else {
    //   return Loader();
    // }
    return FirstGoal();    
  }  
  
  @override
  Widget build(BuildContext context) {
    _goalsProvider = Provider.of<GoalsViewModel>(context);

    return FutureBuilder<void>(
      future: _getGoals(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Stack(
          children: <Widget>[
            const BackgroundGradient(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: _showTitle(),
                backgroundColor: Colors.transparent,          
                elevation: 0.0
              ),
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: false,                
              body: _showContent()
            )
          ],
        );
      }
    );
  }    
}
