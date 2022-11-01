import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/editable_goal_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/tutorial_previews_widget.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/steps_widget.dart';
import 'package:mwb_connect_app/ui/views/quizzes/quiz_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class GoalStepsView extends StatefulWidget {
  const GoalStepsView({Key? key})
    : super(key: key);
    
  @override
  State<StatefulWidget> createState() => _GoalStepsViewState();
}

class _GoalStepsViewState extends State<GoalStepsView> {
  GoalsViewModel? _goalsProvider;  
  QuizzesViewModel? _quizzesProvider;
  bool _isQuizDialogOpen = false;
  bool _isInit = false;

  Widget _showGoalSteps(Orientation orientation) {
    final bool isHorizontal = orientation == Orientation.landscape;
    return Stack(
      children: <Widget>[
        BackgroundGradient(),
        Column(
          children: <Widget>[
            EditableGoal(),
            if (!isHorizontal) TutorialPreviews(),
            if (isHorizontal) SizedBox(height: 20.0),
            Steps()
          ]
        )
      ]
    );
  }

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'goal_steps.title'.tr(),
          textAlign: TextAlign.center
        )
      )
    );
  }

  Future<void> _showQuiz(_) async {
    int remainingQuizzes = _quizzesProvider!.calculateRemainingQuizzes();
    bool wasQuizDialogClosed = _quizzesProvider!.wasClosed;
    if (remainingQuizzes > 0) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted && !_isQuizDialogOpen && !wasQuizDialogClosed) {
        _isQuizDialogOpen = true;
        showDialog(
          context: context,
          builder: (_) => AnimatedDialog(
            widgetInside: QuizView()
          ),
        ).then((_) => _isQuizDialogOpen = false);
      }
    }    
  }

  Widget _showContent(Orientation orientation) {
    if (_isInit) {
      return _showGoalSteps(orientation);
    } else {
      return const Loader();
    }
  }

  List<String> getLogsList() {
    String goalText = 'goal: ';
    if (_goalsProvider?.selectedGoal?.id != null) {
      goalText += _goalsProvider?.selectedGoal?.id as String;
    } else {
      goalText += 'null';
    }
    String quizzesText = 'quizzes: ';
    if (_quizzesProvider?.quizzes != null && _quizzesProvider?.quizzes.length as int > 0) {
      for (Quiz quiz in _quizzesProvider?.quizzes as List<Quiz>) {
        if (quiz.isCorrect == true) {
          quizzesText += quiz.number.toString() + ', ';
        }
      }
      if (quizzesText.contains(',')) {
        quizzesText = quizzesText.substring(0, quizzesText.length - 2);
      }
    } else {
      quizzesText += '[]';
    }
    return [
      goalText,
      quizzesText
    ];
  }  

  Future<void> _init() async {
    if (!_isInit && _goalsProvider != null) {
      for (int i = 0; i < 10; i++) {
        if (_goalsProvider?.selectedGoal == null) {
          await Future.wait([
            _goalsProvider!.getGoals(),
            _quizzesProvider!.getQuizzes()
          ]).timeout(const Duration(seconds: 3600))
          .catchError((error) {
            _goalsProvider?.sendAPIDataLogs(i, error, getLogsList());
          });
          _goalsProvider?.sendAPIDataLogs(i, '', getLogsList());;
        }
      }
      _isInit = true;
    }
  }  

  @override
  Widget build(BuildContext context) {
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _quizzesProvider = Provider.of<QuizzesViewModel>(context);    
    // WidgetsBinding.instance?.addPostFrameCallback(_showQuiz);

    return FutureBuilder<void>(
      future: _init(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Stack(
          children: <Widget>[
            const BackgroundGradient(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: _showTitle(),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: false,
              body: OrientationBuilder(
                builder: (context, orientation){
                  return _showContent(orientation);
                }
              )
            )
          ],
        );
      }
    );
  }
}
