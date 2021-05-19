import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/update_status.dart';
import 'package:mwb_connect_app/core/services/authentication_service_old.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/updates_view_model.dart';
import 'package:mwb_connect_app/ui/views/others/update_app_view.dart';
import 'package:mwb_connect_app/ui/views/quizzes/quiz_view.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/first_goal_widget.dart';
import 'package:mwb_connect_app/ui/views/goals/widgets/goal_card_widget.dart';
import 'package:mwb_connect_app/ui/views/goals/widgets/add_goal_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/drawer_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({Key key, this.auth, this.logoutCallback})
    : super(key: key);  

  final BaseAuth auth;
  final VoidCallback logoutCallback;

  @override
  State<StatefulWidget> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> with WidgetsBindingObserver {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  GoalsViewModel _goalProvider;
  QuizzesViewModel _quizProvider;
  final Axis _scrollDirection = Axis.vertical;  
  final AutoScrollController _scrollController = AutoScrollController();  
  final int _opacityDuration = 300;
  bool _isLoaded = false;
  bool _shouldShowGoals = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout); 
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> reassemble() async {
    super.reassemble();
    //Show quiz
    // await _quizProvider.getQuizNumber();
    // if (_storageService.quizNumber != -1) {
    //   showDialog(
    //     context: context,
    //     builder: (_) => AnimatedDialog(
    //       widgetInside: QuizView(),
    //       hasInput: false
    //     ),
    //   );
    // }
    //Show update
    final UpdatesViewModel updatesViewModel = locator<UpdatesViewModel>();
    final UpdateStatus updateStatus = await updatesViewModel.getUpdateStatus();
    if (updateStatus == UpdateStatus.RECOMMEND_UPDATE) {
      Navigator.push(context, MaterialPageRoute<UpdateAppView>(builder: (_) => UpdateAppView(isForced: false)));
    } else if (updateStatus == UpdateStatus.FORCE_UPDATE) {
      Navigator.push(context, MaterialPageRoute<UpdateAppView>(builder: (_) => UpdateAppView(isForced: true)));
    }
  }  

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  void _afterLayout(_) {
    if (_goalProvider.wasGoalAdded) {
      _scrollToLastGoal();
      _goalProvider.setWasGoalAdded(false);
    }
  }

  void _scrollToLastGoal() {
    _scrollController.scrollToIndex(_goalProvider.goals.length);
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
                itemCount: _goalProvider.goals.length,
                itemBuilder: (BuildContext buildContext, int index) =>
                  AutoScrollTag(
                    key: ValueKey<int>(index),
                    controller: _scrollController,
                    index: index,
                    child: GoalCard(goal: _goalProvider.goals[index])
                  )
              ),
            ),
            if (_goalProvider.goals.isNotEmpty) _showAddGoalButton()
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
          primary: AppColors.MONZA,
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
              widgetInside: const AddGoalDialog(),
              hasInput: true,
            ),
          );
        },        
      )
    );
  }

  Widget _showTitle() {
    Widget title;
    if (_goalProvider.goals == null) {
      title = const Text('');
    } else {
      if (_goalProvider.goals.isNotEmpty) {
        title = Text('goals.my_goals'.tr());
      } else {
        title = Text('goals.first_goal'.tr());
      } 
    }

    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: title
      )
    );
  }

  void _getGoals() {
    _goalProvider.fetchGoals().then((List<Goal> goals) {
      setState(() {
        _isLoaded = true;
      });
    });
  }
  
  Widget _showContent() {
    if (_isLoaded) {
      if (_goalProvider.goals.isNotEmpty) {
        // For opacity animation
        Future<void>.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_shouldShowGoals) {
            setState(() {
              _shouldShowGoals = true;
            });
          }
        });
        return _showGoals();
      } else {
        return FirstGoal();
      }
    } else {
      return Loader();
    }
  }  
  
  @override
  Widget build(BuildContext context) {
    _goalProvider = Provider.of<GoalsViewModel>(context);
    _quizProvider = Provider.of<QuizzesViewModel>(context);

    if (!_isLoaded) {
      _getGoals();
    }

    return Scaffold(
      appBar: AppBar(      
        title: _showTitle(),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          BackgroundGradient(),
          _showContent()
        ]
      )
    );
  }
}
