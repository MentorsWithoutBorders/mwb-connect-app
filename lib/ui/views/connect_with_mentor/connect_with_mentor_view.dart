import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/update_status.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/root_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/update_app_view_model.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/solve_quiz_add_step_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/training_completed_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/next_lesson_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/find_available_mentor_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/finding_available_mentor_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/lessons_stopped_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/lessons_disabled_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/joyful_productivity_reminder_dialog.dart';
import 'package:mwb_connect_app/ui/views/others/update_app_view.dart';
import 'package:mwb_connect_app/ui/widgets/drawer_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class ConnectWithMentorView extends StatefulWidget {
  ConnectWithMentorView({Key? key, this.logoutCallback})
    : super(key: key);  

  final VoidCallback? logoutCallback;

  @override
  State<StatefulWidget> createState() => _ConnectWithMentorViewState();
}

class _ConnectWithMentorViewState extends State<ConnectWithMentorView> with WidgetsBindingObserver {
  ConnectWithMentorViewModel? _connectWithMentorProvider;
  RootViewModel? _rootProvider;
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;
  QuizzesViewModel? _quizzesProvider;
  CommonViewModel? _commonProvider;
  bool _isInit = false;
  bool _isProductivityReminderOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setTimeZone();
      setState(() {
        _isInit = false;
      });
      _checkUpdate();
    }
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _goalsProvider?.setSelectedGoal(null);
    }    
  }

  void _setTimeZone() {
    _commonProvider?.setTimeZone();
  }  

  Future<void> _checkUpdate() async {
    final UpdateAppViewModel updatesProvider = locator<UpdateAppViewModel>();
    final UpdateStatus updateStatus = await updatesProvider.getUpdateStatus();
    if (updateStatus == UpdateStatus.RECOMMEND_UPDATE) {
      Navigator.push(context, MaterialPageRoute<UpdateAppView>(builder: (_) => UpdateAppView(isForced: false)));
    } else if (updateStatus == UpdateStatus.FORCE_UPDATE) {
      Navigator.push(context, MaterialPageRoute<UpdateAppView>(builder: (_) => UpdateAppView(isForced: true)));
    }    
  }

  Future<void> _showJoyfulProductivityReminder(_) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    bool shouldShowProductivityReminder = _connectWithMentorProvider!.getShouldShowProductivityReminder();
    if (mounted && shouldShowProductivityReminder && !_isProductivityReminderOpen) {
      _isProductivityReminderOpen = true;
      _connectWithMentorProvider?.setLastShownProductivityReminderDate();
      showDialog(
        context: context,
        builder: (_) => AnimatedDialog(
          widgetInside: JoyfulProductivityReminderDialog()
        ),
      ).then((_) => _setProductivityReminderClosed());
    }
  }
  
  void _setProductivityReminderClosed() {
    _isProductivityReminderOpen = false;
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }    

  Widget _showConnectWithMentor() {
   final double statusBarHeight = MediaQuery.of(context).padding.top;
   final isTrainingEnabled = _commonProvider!.appFlags.isTrainingEnabled;
   final isMentoringEnabled = _commonProvider!.appFlags.isMentoringEnabled;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 70.0, 15.0, 0.0), 
      child: ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          if (isTrainingEnabled && shouldShowTraining() == true) SolveQuizAddStep(),
          if (isTrainingEnabled && shouldShowTraining() == false && _connectWithMentorProvider?.shouldShowTrainingCompleted() == true) TrainingCompleted(),
          if (isMentoringEnabled && _connectWithMentorProvider?.isNextLesson == true) NextLesson(),
          if (isMentoringEnabled && _connectWithMentorProvider?.isNextLesson == false && _connectWithMentorProvider?.isLessonRequest == false && _connectWithMentorProvider?.shouldStopLessons != true) FindAvailableMentor(shouldReloadCallback: _shouldReloadCallback),
          if (isMentoringEnabled && _connectWithMentorProvider?.isLessonRequest == true && _connectWithMentorProvider?.shouldStopLessons != true) FindingAvailableMentor(),
          if (isMentoringEnabled && _connectWithMentorProvider?.shouldStopLessons == true) LessonsStopped(),
          if (!isMentoringEnabled) LessonsDisabled()
        ]
      )
    );
  }

  bool shouldShowTraining() => _stepsProvider?.getShouldShowAddStep() == true || _quizzesProvider?.getShouldShowQuizzes() == true;

  void _shouldReloadCallback() {
    _isInit = false;
    setState(() {});
    _init();    
  }  

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'connect_with_mentor.title'.tr(),
          textAlign: TextAlign.center
        ),
      )
    );
  }

  Widget _showContent() {
    if (_isInit) {
      return _showConnectWithMentor();
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
    String lastStepAddedText = 'last step added: ';
    if (_stepsProvider?.lastStepAdded.id != null) {
      lastStepAddedText += _stepsProvider?.lastStepAdded.id as String;
    } else {
      lastStepAddedText += 'null';
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
    String lessonRequestText = 'lesson request: ';
    if (_connectWithMentorProvider?.lessonRequest?.id != null) {
      lessonRequestText += _connectWithMentorProvider?.lessonRequest?.id as String;
    } else {
      lessonRequestText += 'null';
    }
    String previousLessonText = 'previous lesson: ';
    if (_connectWithMentorProvider?.previousLesson?.id != null) {
      previousLessonText += _connectWithMentorProvider?.previousLesson?.id as String;
    } else {
      previousLessonText += 'null';
    }
    String nextLessonText = 'next lesson: ';
    if (_connectWithMentorProvider?.nextLesson?.id != null) {
      nextLessonText += _connectWithMentorProvider?.nextLesson?.id as String;
    } else {
      nextLessonText += 'null';
    }
    return [
      goalText,
      lastStepAddedText,
      quizzesText,
      lessonRequestText,
      previousLessonText,
      nextLessonText
    ];
  }
  
  Future<void> _init() async {
    if (!_isInit && _connectWithMentorProvider != null) {
      for (int i = 0; i < 10; i++) {
        if (_goalsProvider?.selectedGoal == null) {
          await Future.wait([
            _rootProvider!.getUserDetails(),
            _connectWithMentorProvider!.getLessonRequest(),
            _connectWithMentorProvider!.getPreviousLesson(),
            _connectWithMentorProvider!.getNextLesson(),
            _connectWithMentorProvider!.getCertificateSent(),
            _goalsProvider!.getGoals(),
            _stepsProvider!.getLastStepAdded(),
            _quizzesProvider!.getQuizzes(),
            _commonProvider!.getAppFlags()
          ]).timeout(const Duration(seconds: 3600))
          .catchError((error) {
            _connectWithMentorProvider?.sendAPIDataLogs(i, error, getLogsList());
          });
          _connectWithMentorProvider?.sendAPIDataLogs(i, '', getLogsList());
        }
      }
      await _commonProvider!.initPushNotifications();
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);
    _rootProvider = Provider.of<RootViewModel>(context);
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context);
    _quizzesProvider = Provider.of<QuizzesViewModel>(context);
    _commonProvider = Provider.of<CommonViewModel>(context);
    WidgetsBinding.instance?.addPostFrameCallback(_showJoyfulProductivityReminder);    

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
                elevation: 0.0
              ),
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: false,
              body: _showContent(),
              drawer: DrawerWidget(
                logoutCallback: widget.logoutCallback as VoidCallback
              )
            )
          ],
        );
      }
    );
  }
}
