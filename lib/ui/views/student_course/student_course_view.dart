import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/update_status.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course/student_course_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/in_app_messages_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/update_app_view_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/course/course_widget.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/course/find_available_course_widget.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/course/waiting_start_course_widget.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/training/solve_quiz_add_step_widget.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/training/training_completed_widget.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/training/joyful_productivity_reminder_dialog.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses_fields/available_courses_fields_view.dart';
import 'package:mwb_connect_app/ui/views/others/update_app_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/drawer_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class StudentCourseView extends StatefulWidget {
  StudentCourseView({Key? key, @required this.logoutCallback}) : super(key: key);

  final VoidCallback? logoutCallback;

  @override
  State<StatefulWidget> createState() => _StudentCourseViewState();
}

class _StudentCourseViewState extends State<StudentCourseView> with WidgetsBindingObserver {
  StudentCourseViewModel? _studentCourseProvider;
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;
  QuizzesViewModel? _quizzesProvider;
  InAppMessagesViewModel? _inAppMessagesProvider;
  CommonViewModel? _commonProvider;
  bool _isInit = false;
  bool _isDataLoaded = false;
  bool _isInAppMessageOpen = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {   
    if (state == AppLifecycleState.resumed) {
      _setTimeZone();
      _reload();
      _checkUpdate();
    }
  }

  void _reload() {
    _commonProvider?.getGoalAttempts = 0;    
    setState(() {
      _isDataLoaded = false;
      _isInit = false;
    });
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

  Future<void> _showInAppMessage(_) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    bool? shouldShowNotification = _inAppMessagesProvider?.inAppMessage?.text?.isNotEmpty;
    if (mounted && shouldShowNotification == true && !_isInAppMessageOpen) {
      _isInAppMessageOpen = true;
      showDialog(
        context: context,
        builder: (_) => AnimatedDialog(
          widgetInside: NotificationDialog(
            text: _inAppMessagesProvider?.inAppMessage?.text,
            buttonText: 'common.ok'.tr(),
            shouldReload: false,
          ))).then((_) => _setInAppMessageClosed());
    } else {
      bool shouldShowProductivityReminder = _studentCourseProvider!.getShouldShowProductivityReminder();
      if (mounted && shouldShowProductivityReminder && !_isInAppMessageOpen) {
        _isInAppMessageOpen = true;
        _studentCourseProvider?.setLastShownProductivityReminderDate();
        showDialog(context: context, builder: (_) => AnimatedDialog(widgetInside: JoyfulProductivityReminderDialog())).then((_) => _setInAppMessageClosed());
      }
    }
  }

  void _setInAppMessageClosed() {
    _isInAppMessageOpen = false;
    _inAppMessagesProvider?.deleteInAppMessage();
  }

  Widget _showTitle() {
    String title = 'student_course.course_title'.tr();
    return Container(padding: const EdgeInsets.only(right: 50.0), child: Center(child: Text(title, textAlign: TextAlign.center)));
  }

  Widget _showContent() {
    if (_isDataLoaded == true) {
      return _showStudentCourse();
    } else {
      return const Loader();
    }
  }

  Widget _showStudentCourse() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bool isTrainingEnabled = _commonProvider!.appFlags.isTrainingEnabled;
    final bool isCourse = _studentCourseProvider?.isCourse as bool;
    final bool isNextLesson = _studentCourseProvider?.isNextLesson as bool;
    final bool isCourseStarted = _studentCourseProvider?.isCourseStarted as bool;
    final CourseMentor? mentorNextLesson = _studentCourseProvider?.nextLesson?.mentor;
    final String? whatsAppGroupUrl = _studentCourseProvider?.course?.whatsAppGroupUrl;
    final List<ColoredText> courseText = _studentCourseProvider?.getCourseText() as List<ColoredText>;
    final List<ColoredText> waitingStartCourseText = _studentCourseProvider?.getWaitingStartCourseText() as List<ColoredText>;
    final List<ColoredText> currentStudentsText = _studentCourseProvider?.getCurrentStudentsText() as List<ColoredText>;
    return Padding(
        padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 70.0, 15.0, 0.0),
        child: ListView(padding: const EdgeInsets.only(top: 0.0), children: [
          if (isTrainingEnabled && shouldShowTraining() == true) SolveQuizAddStep(),
          if (isTrainingEnabled && shouldShowTraining() == false && _studentCourseProvider?.shouldShowTrainingCompleted() == true) TrainingCompleted(),
          if (!isCourse || isCourse && isCourseStarted && !isNextLesson) FindAvailableCourse(onFind: _goToAvailableCoursesFields),
          if (isCourse && isCourseStarted && isNextLesson)
            Course(
                mentorNextLesson: mentorNextLesson,
                text: courseText,
                whatsAppGroupUrl: whatsAppGroupUrl,
                onCancelNextLesson: _cancelNextLesson,
                onCancelCourse: _cancelCourse),
          if (isCourse && !isCourseStarted) 
            WaitingStartCourse(
                text: waitingStartCourseText, 
                currentStudentsText: currentStudentsText, 
                onCancel: _cancelCourse)
        ]));
  }

  Future<void> _cancelNextLesson(String? reason) async {
    await _studentCourseProvider?.cancelNextLesson(reason);
  }

  Future<void> _cancelCourse(String? reason) async {
    await _studentCourseProvider?.cancelCourse(reason);
  }

  Future<void> _goToAvailableCoursesFields() async {
    Navigator.push<CourseModel>(context, MaterialPageRoute(builder: (context) => AvailableCoursesFieldsView())).then((CourseModel? course) {
      if (course != null) {
        _studentCourseProvider?.setCourse(course);
      }
    });
  }

  bool shouldShowTraining() => _stepsProvider?.getShouldShowAddStep() == true || _quizzesProvider?.getShouldShowQuizzes() == true;

  Future<void> _init() async {
    List<String> logsList = _studentCourseProvider!.getLogsList(
      _goalsProvider?.selectedGoal?.id,
      _stepsProvider?.lastStepAdded.id,
      _quizzesProvider?.quizzes
    );
    if (!_isInit && _studentCourseProvider != null) {
      _isInit = true;
      await Future.wait([
        _studentCourseProvider!.getCourse(),
        _studentCourseProvider!.getNextLesson(),
        _studentCourseProvider!.getCertificateSent(),
        _goalsProvider!.getGoals(),
        _stepsProvider!.getLastStepAdded(),
        _quizzesProvider!.getQuizzes(),
        _inAppMessagesProvider!.getInAppMessage(),
        _commonProvider!.getAppFlags()
      ]).timeout(const Duration(seconds: 3600)).catchError((error) {
        _studentCourseProvider?.sendAPIDataLogs(_commonProvider!.getGoalAttempts, error, logsList);
      });
      _studentCourseProvider?.sendAPIDataLogs(_commonProvider!.getGoalAttempts, '', logsList);
      await _commonProvider!.initPushNotifications();
      if (_goalsProvider?.selectedGoal == null && _commonProvider!.getGoalAttempts < 10) {
        _commonProvider!.getGoalAttempts++;
        _reload();
      } else {
        setState(() {
          _isDataLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _studentCourseProvider = Provider.of<StudentCourseViewModel>(context);
    _goalsProvider = Provider.of<GoalsViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context);
    _quizzesProvider = Provider.of<QuizzesViewModel>(context);
    _inAppMessagesProvider = Provider.of<InAppMessagesViewModel>(context);
    _commonProvider = Provider.of<CommonViewModel>(context);
    WidgetsBinding.instance.addPostFrameCallback(_showInAppMessage);

    return FutureBuilder<void>(
      future: _init(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Stack(
          children: <Widget>[
            const BackgroundGradient(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(title: _showTitle(), backgroundColor: Colors.transparent, elevation: 0.0),
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: false,
              body: _showContent(),
              drawer: DrawerWidget(logoutCallback: widget.logoutCallback as VoidCallback))
          ],
        );
      });
  }
}
