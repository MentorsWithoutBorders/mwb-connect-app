import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/solve_quiz_add_step_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/next_lesson_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/find_available_mentor_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/finding_available_mentor_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/learned_today_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/drawer_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class ConnectWithMentorView extends StatefulWidget {
  ConnectWithMentorView({Key key, this.logoutCallback})
    : super(key: key);  

  final VoidCallback logoutCallback;

  @override
  State<StatefulWidget> createState() => _ConnectWithMentorViewState();
}

class _ConnectWithMentorViewState extends State<ConnectWithMentorView> {
  ConnectWithMentorViewModel _connectWithMentorProvider;
  bool _isInit = false;

  @override
  Future<void> reassemble() async {
    super.reassemble();
    // Show learned today
    // showDialog(
    //   context: context,
    //   builder: (_) => AnimatedDialog(
    //     widgetInside: LearnedTodayDialog(),
    //     hasInput: false
    //   ),
    // );
  }    

  Widget _showConnectWithMentor() {
   final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 70.0, 15.0, 0.0), 
      child: ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          if (_connectWithMentorProvider.shouldShowTraining) SolveQuizAddStep(),
          if (_connectWithMentorProvider.isNextLesson) NextLesson(),
          if (!_connectWithMentorProvider.isNextLesson && !_connectWithMentorProvider.isLessonRequest) FindAvailableMentor(),
          if (_connectWithMentorProvider.isLessonRequest) FindingAvailableMentor()
        ]
      )
    );
  }

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
    if (!_isInit) {
      await _connectWithMentorProvider.getGoal();
      await _connectWithMentorProvider.getLastStepAdded();
      await _connectWithMentorProvider.getQuizNumber();
      await _connectWithMentorProvider.getLessonRequest();
      await _connectWithMentorProvider.getNextLesson();
      _isInit = true;
    }
    if (_connectWithMentorProvider.shouldReload) {
      _isInit = false;
      await _connectWithMentorProvider.getLastStepAdded();
      _connectWithMentorProvider.shouldReload = false;
      _isInit = true;
    }    
  }

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

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
