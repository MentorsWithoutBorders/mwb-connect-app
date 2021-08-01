import 'package:flutter/material.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/solve_quiz_add_step_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/standing_by_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/lesson_request_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/next_lesson_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/drawer_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class LessonRequestView extends StatefulWidget {
  LessonRequestView({Key key, this.logoutCallback})
    : super(key: key);  

  final VoidCallback logoutCallback;

  @override
  State<StatefulWidget> createState() => _LessonRequestViewState();
}

class _LessonRequestViewState extends State<LessonRequestView> with WidgetsBindingObserver {
  LessonRequestViewModel _lessonRequestProvider;
  CommonViewModel _commonProvider;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isInit = false;
      if (!_checkAppReload()) {
        _setPreferences();
        setState(() {});
        _init();
      }
    }
  }

  bool _checkAppReload() {
    return _commonProvider.checkAppReload();
  }    
  
  void _setPreferences() {
    _commonProvider.setPreferences();   
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }  
  

  Widget _showLessonRequest() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 70.0, 15.0, 0.0), 
      child: ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          if (_lessonRequestProvider.shouldShowTraining) SolveQuizAddStep(),
          if (!_lessonRequestProvider.isNextLesson && !_lessonRequestProvider.isLessonRequest) StandingBy(),
          if (_lessonRequestProvider.isLessonRequest) LessonRequest(),
          if (_lessonRequestProvider.isNextLesson) NextLesson()
        ]
      )
    );
  }

  Widget _showTitle() {
    String title = 'lesson_request.title'.tr();
    if (_lessonRequestProvider.isNextLesson) {
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
    if (!_isInit) {
      await _lessonRequestProvider.getGoal();
      await _lessonRequestProvider.getLastStepAdded();
      await _lessonRequestProvider.getQuizNumber();
      await _lessonRequestProvider.getLessonRequest();
      _showExpiredLessonRequest();
      _showCanceledLessonRequest();
      await _lessonRequestProvider.getNextLesson();
      await _lessonRequestProvider.getPreviousLesson();
      _isInit = true;
    }
  }

  void _showExpiredLessonRequest() {
    if (_lessonRequestProvider.shouldShowExpired) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedDialog(
            widgetInside: NotificationDialog(text: 'lesson_request.lesson_request_expired'.tr(), shouldReload: false)
          );
        }
      );
    }
  }

  void _showCanceledLessonRequest() {
    if (_lessonRequestProvider.shouldShowCanceled) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedDialog(
            widgetInside: NotificationDialog(text: 'lesson_request.lesson_request_canceled'.tr(), shouldReload: false)
          );
        }
      );
    }
  }    

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);
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
                logoutCallback: widget.logoutCallback
              )
            )
          ],
        );
      }
    );
  }
}
