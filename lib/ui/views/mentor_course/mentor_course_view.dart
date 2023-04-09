import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/update_status.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/next_lesson_mentor_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/mentor_parternship_result_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_schedule_item_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentor_course_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/in_app_messages_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/update_app_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course_types/course_types_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/course_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/waiting_students_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/mentor_partnership_request/mentor_partnership_request_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/mentor_partnership_request/waiting_mentor_partnership_request_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/mentor_partnership_request/waiting_mentor_partnership_approval_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/training/solve_quiz_add_step_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/training/training_completed_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests/mentors_waiting_requests_view.dart';
import 'package:mwb_connect_app/ui/views/others/update_app_view.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/drawer_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

import 'widgets/course/set_meeting_url_dialog_widget.dart';

class MentorCourseView extends StatefulWidget {
  MentorCourseView({Key? key, this.logoutCallback}) : super(key: key);

  final VoidCallback? logoutCallback;

  @override
  State<StatefulWidget> createState() => _MentorCourseViewState();
}

class _MentorCourseViewState extends State<MentorCourseView> with WidgetsBindingObserver {
  MentorCourseViewModel? _mentorCourseProvider;
  GoalsViewModel? _goalsProvider;
  StepsViewModel? _stepsProvider;
  QuizzesViewModel? _quizzesProvider;
  InAppMessagesViewModel? _inAppMessagesProvider;
  CommonViewModel? _commonProvider;
  bool _isInit = false;
  bool _wasMeetingUrlDialogShown = false;
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
      _wasMeetingUrlDialogShown = false;
      _setTimeZone();
      _reload();
      _checkUpdate();
    }
  }

  void _reload() {
    setState(() {
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
    }
  }

  void _setInAppMessageClosed() {
    _isInAppMessageOpen = false;
    _inAppMessagesProvider?.deleteInAppMessage();
  }

  Widget _showTitle() {
    String title = 'mentor_course.course_title'.tr();
    return Container(padding: const EdgeInsets.only(right: 50.0), child: Center(child: Text(title, textAlign: TextAlign.center)));
  }

  Widget _showContent() {
    if (_isInit) {
      return _showMentorCourse();
    } else {
      return const Loader();
    }
  }

  Widget _showMentorCourse() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isTrainingEnabled = _commonProvider!.appFlags.isTrainingEnabled;
    User user = _commonProvider?.user as User;
    final CourseMentor mentor = CourseMentor.fromJson(user.toJson());
    final bool isCourse = _mentorCourseProvider?.isCourse ?? false;
    final bool isNextLesson = _mentorCourseProvider?.isNextLesson ?? false;
    final bool isCourseStarted = _mentorCourseProvider?.isCourseStarted ?? false;
    final bool isMentorPartnershipRequest = _mentorCourseProvider?.isMentorPartnershipRequest ?? false;
    final bool isMentorPartnershipRequestWaitingApproval = _mentorCourseProvider?.getIsMentorPartnershipRequestWaitingApproval(mentor) ?? false;
    final bool isMentorWaitingRequest = _mentorCourseProvider?.isMentorWaitingRequest ?? false;
    // Courses types
    final List<CourseType>? courseTypes = _mentorCourseProvider?.courseTypes;
    final CourseType? selectedCourseType = _mentorCourseProvider?.selectedCourseType;
    final List<Subfield>? subfields = mentor.field?.subfields as List<Subfield>;
    // Course
    final CourseModel? course = _mentorCourseProvider?.course;
    final NextLessonMentor? nextLesson = _mentorCourseProvider?.nextLesson;
    final int mentorsCount = _mentorCourseProvider?.getMentorsCount() as int;
    final List<MentorPartnershipScheduleItemModel>? mentorPartnershipSchedule = _mentorCourseProvider?.mentorPartnershipSchedule;
    final int studentsCount = _mentorCourseProvider?.getStudentsCount() as int;
    final String meetingUrl = _mentorCourseProvider?.getMeetingUrl() as String;
    final List<ColoredText> waitingStudentsNoPartnerText = _mentorCourseProvider?.getWaitingStudentsNoPartnerText() as List<ColoredText>;
    final List<ColoredText> waitingStudentsPartnerText = _mentorCourseProvider?.getWaitingStudentsPartnerText() as List<ColoredText>;
    final List<ColoredText> maximumStudentsText = _mentorCourseProvider?.getMaximumStudentsText() as List<ColoredText>;
    final List<ColoredText> currentStudentsText = _mentorCourseProvider?.getCurrentStudentsText() as List<ColoredText>;
    final List<ColoredText>? courseText = _mentorCourseProvider?.getCourseText();
    final List<ColoredText>? mentorPartnershipScheduleText = _mentorCourseProvider?.getMentorPartnershipScheduleText();
    final String cancelCourseText = _mentorCourseProvider?.getCancelCourseText() as String;
    // Mentor partnership request
    final String requestPartnerMentorName = _mentorCourseProvider?.getRequestPartnerMentorName() ?? '';
    final List<ColoredText>? mentorPartnershipText = _mentorCourseProvider?.getMentorPartnershipText();
    final List<ColoredText>? mentorPartnershipBottomText = _mentorCourseProvider?.getMentorPartnershipBottomText();
    final List<ColoredText>? waitingMentorPartnershipApprovalText = _mentorCourseProvider?.getWaitingMentorPartnershipApprovalText();
    final bool? shouldUnfocus = _mentorCourseProvider?.shouldUnfocus;
    return Padding(
        padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 70.0, 15.0, 0.0),
        child: ListView(padding: const EdgeInsets.only(top: 0.0), children: [
          if (isTrainingEnabled && shouldShowTraining() == true) 
            SolveQuizAddStep(),
          if (isTrainingEnabled && shouldShowTraining() == false && _mentorCourseProvider?.shouldShowTrainingCompleted() == true) 
            TrainingCompleted(),
          if ((!isCourse || isCourse && isCourseStarted && !isNextLesson) && !isMentorPartnershipRequest && !isMentorWaitingRequest)
            CourseTypes(
                courseTypes: courseTypes,
                selectedCourseType: selectedCourseType,
                subfields: subfields,
                onSelect: _setSelectedCourseType,
                onSetCourseDetails: _setCourseDetails,
                onFindPartner: _findPartner),
          if (isCourse && !isCourseStarted)
            WaitingStudents(
                mentorsCount: mentorsCount,
                studentsCount: studentsCount,
                waitingStudentsNoPartnerText: waitingStudentsNoPartnerText,
                waitingStudentsPartnerText: waitingStudentsPartnerText,
                maximumStudentsText: maximumStudentsText,
                currentStudentsText: currentStudentsText,
                cancelText: cancelCourseText,
                onCancel: _cancelCourse),
          if (isCourse && isCourseStarted && isNextLesson)
            Course(
                course: course,
                nextLesson: nextLesson,
                mentorPartnershipSchedule: mentorPartnershipSchedule,
                meetingUrl: meetingUrl,
                text: courseText,
                mentorPartnershipScheduleText: mentorPartnershipScheduleText,
                cancelCourseText: cancelCourseText,
                onSetMeetingUrl: _setMeetingUrl,
                onSetWhatsAppGroupUrl: _setWhatsAppGroupUrl,
                onUpdateNotes: _updateCourseNotes,
                onUpdateScheduleItem: _updateMentorPartnershipScheduleItem,
                onCancelNextLesson: _cancelNextLesson,
                onCancelCourse: _cancelCourse),
          if (isMentorPartnershipRequest && !isMentorPartnershipRequestWaitingApproval)
            MentorPartnershipRequest(
                text: mentorPartnershipText,
                bottomText: mentorPartnershipBottomText,
                onAccept: _acceptMentorPartnershipRequest,
                onReject: _rejectMentorPartnershipRequest,
                shouldUnfocus: shouldUnfocus,
                setShouldUnfocus: _setShouldUnfocus),
          if (isMentorPartnershipRequest && isMentorPartnershipRequestWaitingApproval)
            WaitingMentorPartnershipApproval(
                partnerMentorName: requestPartnerMentorName, 
                text: waitingMentorPartnershipApprovalText, 
                onCancel: _cancelMentorPartnershipRequest),
          if (isMentorWaitingRequest) WaitingMentorPartnershipRequest(onCancel: _cancelMentorWaitingRequest, onFindPartner: _findPartner)
        ]));
  }

  void _setSelectedCourseType(String courseTypeId) {
    _mentorCourseProvider?.setSelectedCourseType(courseTypeId);
  }

  Future<void> _setCourseDetails(String subfieldId, Availability? availability, String meetingUrl) async {
    await _addCourse(availability, meetingUrl);
  }

  Future<void> _addCourse(Availability? availability, String meetingUrl) async {
    await _mentorCourseProvider?.addCourse(availability, meetingUrl);
  }

  void _findPartner() {
    CourseType selectedCourseType = _mentorCourseProvider?.selectedCourseType ?? CourseType();
    _goToMentorsWaitingRequests(selectedCourseType);
  }

  Future<void> _setMeetingUrl(String meetingUrl) async {
    await _mentorCourseProvider?.setMeetingUrl(meetingUrl);
    final bool isCourse = _mentorCourseProvider?.isCourse ?? false;
    final bool isCourseStarted = _mentorCourseProvider?.isCourseStarted ?? false;    
    if (isCourse && !isCourseStarted) {
      _showMeetingUrlToast(context);
    }
  }

  void _showMeetingUrlToast(BuildContext context) {
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('mentor_course.lessons_url_confirmation'.tr()),
        action: SnackBarAction(
          label: 'common.close'.tr(), 
          onPressed: scaffold.hideCurrentSnackBar
        ),
      ),
    );
  }  

  Future<void> _setWhatsAppGroupUrl(String whatsAppGroupUrl) async {
    await _mentorCourseProvider?.setWhatsAppGroupUrl(whatsAppGroupUrl);
  }

  Future<void> _updateCourseNotes(String? notes) async {
    await _mentorCourseProvider?.updateCourseNotes(notes);
  }

  Future<void> _updateMentorPartnershipScheduleItem(String? scheduleItemId, String? mentorId) async {
    await _mentorCourseProvider?.updateMentorPartnershipScheduleItem(scheduleItemId, mentorId);
  }

  Future<void> _cancelNextLesson(String? reason) async {
    await _mentorCourseProvider?.cancelNextLesson(reason);
  }

  Future<void> _cancelCourse(String? reason) async {
    await _mentorCourseProvider?.cancelCourse(reason);
  }

  Future<void> _acceptMentorPartnershipRequest(String? url) async {
    await _mentorCourseProvider?.acceptMentorPartnershipRequest(url);
    CourseModel? course = _mentorCourseProvider?.course;
    if (course?.id == null) {
      _reload();
    }
  }

  Future<void> _rejectMentorPartnershipRequest(String? reason) async {
    await _mentorCourseProvider?.rejectMentorPartnershipRequest(reason);
    _reload();
  }

  Future<void> _cancelMentorPartnershipRequest() async {
    await _mentorCourseProvider?.cancelMentorPartnershipRequest();
  }

  Future<void> _cancelMentorWaitingRequest() async {
    await _mentorCourseProvider?.cancelMentorWaitingRequest();
  }

  void _setShouldUnfocus(bool shouldUnfocus) {
    _mentorCourseProvider?.shouldUnfocus = shouldUnfocus;
  }

  void _goToMentorsWaitingRequests(CourseType selectedCourseType) {
    User user = _commonProvider?.user as User;
    final CourseMentor mentor = CourseMentor.fromJson(user.toJson());
    final Field? field = _mentorCourseProvider?.field;
    final List<CourseType>? courseTypes = _mentorCourseProvider?.courseTypes;
    MentorPartnershipRequestModel mentorPartnershipRequest = MentorPartnershipRequestModel(mentor: mentor, courseType: selectedCourseType);
    Navigator.push<MentorPartnershipResult>(
      context,
      MaterialPageRoute(
        builder: (context) => MentorsWaitingRequestsView(
          field: field, 
          courseTypes: courseTypes, 
          mentorPartnershipRequest: mentorPartnershipRequest
        )
      )
    ).then((MentorPartnershipResult? result) {
      if (result != null) {
        _mentorCourseProvider?.setMentorPartnershipRequest(result.mentorPartnershipRequest);
        _mentorCourseProvider?.setMentorWaitingRequest(result.mentorWaitingRequest);
      }
    });
  }

  bool shouldShowTraining() => _stepsProvider?.getShouldShowAddStep() == true || _quizzesProvider?.getShouldShowQuizzes() == true;

  Future<void> _init() async {
    final User user = _commonProvider?.user as User;
    final String fieldId = user.field?.id as String;
    if (!_isInit && _mentorCourseProvider != null) {
      await Future.wait([
        _mentorCourseProvider!.getCourseTypes(),
        _mentorCourseProvider!.getCourse(),
        _mentorCourseProvider!.getNextLesson(),
        _mentorCourseProvider!.getField(fieldId),
        _mentorCourseProvider!.getMentorPartnershipRequest(),
        _mentorCourseProvider!.getMentorWaitingRequest(),
        _goalsProvider!.getGoals(),
        _stepsProvider!.getLastStepAdded(),
        _quizzesProvider!.getQuizzes(),
        _inAppMessagesProvider!.getInAppMessage(),
        _commonProvider!.getAppFlags()
      ]).timeout(const Duration(seconds: 3600));
      _mentorCourseProvider!.getMentorPartnershipSchedule();
      _showSetMeetingUrlDialog();
      _showExpiredMentorPartnershipRequest();
      _showCanceledMentorPartnershipRequest();
      await _commonProvider!.initPushNotifications();
      _isInit = true;
    }
  }

  void _showSetMeetingUrlDialog() {
    final bool isCourse = _mentorCourseProvider?.isCourse ?? false;
    final String meetingUrl = _mentorCourseProvider?.getMeetingUrl() as String;
    final int mentorsCount = _mentorCourseProvider?.getMentorsCount() as int;
    if (isCourse && meetingUrl.isEmpty && !_wasMeetingUrlDialogShown) {
      _wasMeetingUrlDialogShown = true;
      showDialog(
        context: context,
        builder: (_) => AnimatedDialog(
          widgetInside: SetMeetingUrlDialog(
            meetingUrl: meetingUrl,
            mentorsCount: mentorsCount, 
            isUpdate: false, 
            onSet: _setMeetingUrl
          )
        )
      );
    }
  }

  void _showExpiredMentorPartnershipRequest() {
    if (_mentorCourseProvider?.shouldShowExpired == true) {
      _mentorCourseProvider?.shouldShowExpired = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedDialog(
            widgetInside: NotificationDialog(
              text: 'mentor_course.mentor_partnership_request_expired'.tr(), 
              buttonText: 'common.ok'.tr(), 
              shouldReload: false
            )
          );
        }
      );
    }
  }

  void _showCanceledMentorPartnershipRequest() {
    if (_mentorCourseProvider?.shouldShowCanceled == true) {
      _mentorCourseProvider?.shouldShowCanceled = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedDialog(
            widgetInside: NotificationDialog(
              text: 'mentor_course.mentor_partnership_request_canceled'.tr(), 
              buttonText: 'common.ok'.tr(), 
              shouldReload: false)
            );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);
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
      });
  }
}
