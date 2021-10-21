import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/update_status.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
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
import 'package:mwb_connect_app/ui/views/others/update_app_view.dart';
import 'package:mwb_connect_app/ui/widgets/drawer_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class ConnectWithMentorView extends StatefulWidget {
  ConnectWithMentorView({Key? key, this.logoutCallback})
    : super(key: key);  

  final VoidCallback? logoutCallback;

  @override
  State<StatefulWidget> createState() => _ConnectWithMentorViewState();
}

class _ConnectWithMentorViewState extends State<ConnectWithMentorView> with WidgetsBindingObserver {
  ConnectWithMentorViewModel? _connectWithMentorProvider;
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;
  QuizzesViewModel? _quizzesProvider;
  CommonViewModel? _commonProvider;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  } 

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isInit = false;
      _setTimeZone();
      if (_checkAppReload() == false) {
        _setPreferences();
        setState(() {});
        _init();
      }
      _checkUpdate();
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
  
  bool? _checkAppReload() {
    return _commonProvider?.checkAppReload();
  }    
  
  void _setPreferences() {
    _commonProvider?.setPreferences();   
  }  
  
  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }    

  Widget _showConnectWithMentor() {
   final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 70.0, 15.0, 0.0), 
      child: ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          if (shouldShowTraining() == true) SolveQuizAddStep(),
          if (shouldShowTraining() == false && _connectWithMentorProvider?.shouldShowTrainingCompleted() == true) TrainingCompleted(),          
          if (_connectWithMentorProvider?.isNextLesson == true) NextLesson(),
          if (_connectWithMentorProvider?.isNextLesson == false && _connectWithMentorProvider?.isLessonRequest == false && _connectWithMentorProvider?.shouldStopLessons != true) FindAvailableMentor(),
          if (_connectWithMentorProvider?.isLessonRequest == true && _connectWithMentorProvider?.shouldStopLessons != true) FindingAvailableMentor(),
          if (_connectWithMentorProvider?.shouldStopLessons == true) LessonsStopped()
        ]
      )
    );
  }

  bool shouldShowTraining() => _connectWithMentorProvider?.getShouldShowAddStep() == true || _quizzesProvider?.getShouldShowQuizzes() == true;

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text('connect_with_mentor.title'.tr()),
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
  
  Future<void> _init() async {
    if (!_isInit && _connectWithMentorProvider != null) {
      await Future.wait([
        _connectWithMentorProvider!.getGoal(),
        _connectWithMentorProvider!.getLessonRequest(),
        _connectWithMentorProvider!.getNextLesson(),
        _stepsProvider!.getLastStepAdded(),
        _quizzesProvider!.getQuizzes(),
      ]);
      _setSelectedGoal();
      await _commonProvider!.initPushNotifications();
      _isInit = true;
    }
  }

  void _setSelectedGoal() {
    _goalsProvider?.setSelectedGoal(_connectWithMentorProvider?.goal);
  }  

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context);
    _quizzesProvider = Provider.of<QuizzesViewModel>(context);
    _commonProvider = Provider.of<CommonViewModel>(context);

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
