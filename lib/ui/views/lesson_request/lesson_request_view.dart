import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/standing_by_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/lesson_request_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/next_lesson_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/taught_today_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/drawer_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class LessonRequestView extends StatefulWidget {
  LessonRequestView({Key key, this.logoutCallback})
    : super(key: key);  

  final VoidCallback logoutCallback;

  @override
  State<StatefulWidget> createState() => _LessonRequestViewState();
}

class _LessonRequestViewState extends State<LessonRequestView> {
  LessonRequestViewModel _lessonRequestProvider;
  bool _isInit = false;
  
  @override
  Future<void> reassemble() async {
    super.reassemble();
    // Show learned today
    // showDialog(
    //   context: context,
    //   builder: (_) => AnimatedDialog(
    //     widgetInside: TaughtTodayDialog(),
    //     hasInput: false
    //   ),
    // );
  }      

  Widget _showLessonRequest() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 70.0, 15.0, 0.0), 
      child: ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          if (!_lessonRequestProvider.getIsNextLesson() && !_lessonRequestProvider.getIsLessonRequest()) StandingBy(),
          if (_lessonRequestProvider.getIsLessonRequest()) LessonRequest(),
          if (_lessonRequestProvider.getIsNextLesson()) NextLesson()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text('lesson_request.title'.tr()),
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
      await _lessonRequestProvider.getLessonRequest();
      await _lessonRequestProvider.getNextLesson();
      _isInit = true;
    }
  }  

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

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
