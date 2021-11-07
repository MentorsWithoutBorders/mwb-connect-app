import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/update_status.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/update_app_view_model.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/solve_quiz_add_step_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/training_completed_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/standing_by_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/lesson_request_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/next_lesson_widget.dart';
import 'package:mwb_connect_app/ui/views/others/update_app_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/drawer_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class LessonRequestView extends StatefulWidget {
  LessonRequestView({Key? key, this.logoutCallback})
    : super(key: key);  

  final VoidCallback? logoutCallback;

  @override
  State<StatefulWidget> createState() => _LessonRequestViewState();
}

class _LessonRequestViewState extends State<LessonRequestView> with WidgetsBindingObserver {
  LessonRequestViewModel? _lessonRequestProvider;
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;
  QuizzesViewModel? _quizzesProvider;
  CommonViewModel? _commonProvider;
  bool _isInit = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  } 

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _isInit = false;
      _setTimeZone();
      setState(() {});
      _init();
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

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }  
  

  Widget _showLessonRequest() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isTrainingEnabled = _commonProvider!.appFlags.isTrainingEnabled;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 70.0, 15.0, 0.0), 
      child: ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          if (isTrainingEnabled && shouldShowTraining() == true) SolveQuizAddStep(),
          if (isTrainingEnabled && shouldShowTraining() == false && _lessonRequestProvider?.shouldShowTrainingCompleted() == true) TrainingCompleted(),
          if (_lessonRequestProvider?.isNextLesson == false && _lessonRequestProvider?.isLessonRequest == false) StandingBy(),
          if (_lessonRequestProvider?.isLessonRequest == true) LessonRequest(),
          if (_lessonRequestProvider?.isNextLesson == true) NextLesson()
        ]
      )
    );
  }

  bool shouldShowTraining() => _stepsProvider?.getShouldShowAddStep() == true || _quizzesProvider?.getShouldShowQuizzes() == true;  

  Widget _showTitle() {
    String title = 'lesson_request.title'.tr();
    if (_lessonRequestProvider?.isNextLesson == true) {
      title = 'lesson_request.scheduled_lesson'.tr();
    }
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(title),
      )
    );
  }

 Widget _showContent() {
    if (_isInit) {
      return _showLessonRequest();
    } else {
      return const Loader();
    }
  }
  
  Future<void> _init() async {
    if (!_isInit && _lessonRequestProvider != null) {
      await Future.wait([
        _lessonRequestProvider!.getGoal(),
        _lessonRequestProvider!.getLessonRequest(),
        _lessonRequestProvider!.getNextLesson(),
        _lessonRequestProvider!.getPreviousLesson(),
        _stepsProvider!.getLastStepAdded(),
        _quizzesProvider!.getQuizzes(),
        _commonProvider!.getAppFlags()
      ]);
      _setSelectedGoal();
      _showExpiredLessonRequest();
      _showCanceledLessonRequest();      
      await _commonProvider!.initPushNotifications();
      _isInit = true;
    }
  }

  void _setSelectedGoal() {
    _goalsProvider?.setSelectedGoal(_lessonRequestProvider?.goal);
  }

  void _showExpiredLessonRequest() {
    if (_lessonRequestProvider?.shouldShowExpired == true) {
      _lessonRequestProvider?.shouldShowExpired = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedDialog(
            widgetInside: NotificationDialog(
              text: 'lesson_request.lesson_request_expired'.tr(),
              buttonText: 'common.ok'.tr(),
              shouldReload: false
            )
          );
        }
      );
    }
  }

  void _showCanceledLessonRequest() {
    if (_lessonRequestProvider?.shouldShowCanceled == true) {
      _lessonRequestProvider?.shouldShowCanceled = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedDialog(
            widgetInside: NotificationDialog(
              text: 'lesson_request.lesson_request_canceled'.tr(),
              buttonText: 'common.ok'.tr(),
              shouldReload: false
            )
          );
        }
      );
    }
  }    

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);
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
