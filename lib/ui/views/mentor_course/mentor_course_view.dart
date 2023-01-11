import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/update_status.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentor_course_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/in_app_messages_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/update_app_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/courses_types/courses_types_widget.dart';
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

class MentorCourseView extends StatefulWidget {
  MentorCourseView({Key? key, this.logoutCallback})
    : super(key: key);  

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
  bool _isInAppMessageOpen = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
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
          )
        )
      ).then((_) => _setInAppMessageClosed());
    }
  }
  
  void _setInAppMessageClosed() {
    _isInAppMessageOpen = false;
    _inAppMessagesProvider?.deleteInAppMessage();
  }
  

  Widget _showTitle() {
    String title = 'mentor_course.course_title'.tr();
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center
        )
      )
    );
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
    // final int minStudentsCourse = AppConstants.minStudentsCourse;
    final int minStudentsCourse = 2;
    User user = _commonProvider?.user as User;
    final CourseMentor mentor = CourseMentor.fromJson(user.toJson());
    final bool isCourse = _mentorCourseProvider?.isCourse ?? false;
    final bool isMentorPartnershipRequest = _mentorCourseProvider?.isMentorPartnershipRequest ?? false;
    final bool isMentorPartnershipRequestWaitingApproval = _mentorCourseProvider?.getIsMentorPartnershipRequestWaitingApproval(mentor) ?? false;
    final bool isMentorWaitingRequest = _mentorCourseProvider?.isMentorWaitingRequest ?? false;
    // Courses types
    final List<CourseType>? coursesTypes = _mentorCourseProvider?.coursesTypes;
    final CourseType? selectedCourseType = _mentorCourseProvider?.selectedCourseType;
    final List<Subfield>? subfields = mentor.field?.subfields as List<Subfield>;
    // Course
    final List<CourseStudent> students = _mentorCourseProvider?.course?.students ?? [];
    final int mentorsCount = _mentorCourseProvider?.getMentorsCount() as int;
    final int studentsCount = _mentorCourseProvider?.getStudentsCount() as int;
    final String meetingUrl = _mentorCourseProvider?.getMeetingUrl() as String;
    final List<ColoredText> waitingStudentsNoPartnerText = _mentorCourseProvider?.getWaitingStudentsNoPartnerText() as List<ColoredText>;
    final List<ColoredText> waitingStudentsPartnerText = _mentorCourseProvider?.getWaitingStudentsPartnerText() as List<ColoredText>;
    final List<ColoredText> maximumStudentsText = _mentorCourseProvider?.getMaximumStudentsText() as List<ColoredText>;
    final List<ColoredText> currentStudentsText = _mentorCourseProvider?.getCurrentStudentsText() as List<ColoredText>;
    final List<ColoredText>? courseText = _mentorCourseProvider?.getCourseText();
    final String cancelCourseText = _mentorCourseProvider?.getCancelCourseText() as String;
    // Mentor partnership request
    final String requestPartnerMentorName = _mentorCourseProvider?.getRequestPartnerMentorName() ?? '';
    final List<ColoredText>? mentorPartnershipText = _mentorCourseProvider?.getMentorPartnershipText();
    final List<ColoredText>? mentorPartnershipBottomText = _mentorCourseProvider?.getMentorPartnershipBottomText();
    final List<ColoredText>? waitingMentorPartnershipApprovalText = _mentorCourseProvider?.getWaitingMentorPartnershipApprovalText();
    final bool? shouldUnfocus = _mentorCourseProvider?.shouldUnfocus;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 70.0, 15.0, 0.0), 
      child: ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          if (isTrainingEnabled && shouldShowTraining() == true) SolveQuizAddStep(),
          if (isTrainingEnabled && shouldShowTraining() == false && _mentorCourseProvider?.shouldShowTrainingCompleted() == true) TrainingCompleted(),
          if (!isCourse && !isMentorPartnershipRequest && !isMentorWaitingRequest) CoursesTypes(
            coursesTypes: coursesTypes,
            selectedCourseType: selectedCourseType,
            subfields: subfields,
            onSelect: _setSelectedCourseType, 
            onSetCourseDetails: _setCourseDetails,
            onFindPartner: _findPartner
          ),
          if (isCourse && students.length < minStudentsCourse) WaitingStudents(
            mentorsCount: mentorsCount,
            studentsCount: studentsCount,
            waitingStudentsNoPartnerText: waitingStudentsNoPartnerText,
            waitingStudentsPartnerText: waitingStudentsPartnerText,
            maximumStudentsText: maximumStudentsText,
            currentStudentsText: currentStudentsText,
            cancelText: cancelCourseText,
            onCancel: _cancelCourse
          ),
          if (isCourse && students.length >= minStudentsCourse) Course(
            text: courseText,
            students: students,
            meetingUrl: meetingUrl,
            cancelText: cancelCourseText,
            onUpdateMeetingUrl: _updateMeetingUrl,
            onCancel: _cancelCourse
          ),
          if (isMentorPartnershipRequest && !isMentorPartnershipRequestWaitingApproval) MentorPartnershipRequest(
            text: mentorPartnershipText,
            bottomText: mentorPartnershipBottomText,
            onAccept: _acceptMentorPartnershipRequest,
            onReject: _rejectMentorPartnershipRequest,
            shouldUnfocus: shouldUnfocus,
            setShouldUnfocus: _setShouldUnfocus
          ),
          if (isMentorPartnershipRequest && isMentorPartnershipRequestWaitingApproval) WaitingMentorPartnershipApproval(
            partnerMentorName: requestPartnerMentorName,
            text: waitingMentorPartnershipApprovalText,
            onCancel: _cancelMentorPartnershipRequest
          ),
          if (isMentorWaitingRequest) WaitingMentorPartnershipRequest(
            onCancel: _cancelMentorWaitingRequest,
            onFindPartner: _findPartner
          )
        ]
      )
    );
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

  Future<void> _updateMeetingUrl(String meetingUrl) async {
    await _mentorCourseProvider?.updateMeetingUrl(meetingUrl);
  }

  Future<void> _cancelCourse(String? reason) async {
    await _mentorCourseProvider?.cancelCourse(reason);
  }

  Future<void> _acceptMentorPartnershipRequest(String? url) async {
    await _mentorCourseProvider?.acceptMentorPartnershipRequest(url);
  }   

  Future<void> _rejectMentorPartnershipRequest(String? reason) async {
    await _mentorCourseProvider?.rejectMentorPartnershipRequest(reason);
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
    MentorPartnershipRequestModel mentorPartnershipRequest = MentorPartnershipRequestModel(
      mentor: mentor,
      courseType: selectedCourseType
    );
    Navigator.push<MentorPartnershipRequestModel>(
      context,
      MaterialPageRoute(
        builder: (context) => MentorsWaitingRequestsView(mentorPartnershipRequest: mentorPartnershipRequest)
      )
    ).then((MentorPartnershipRequestModel? result) {
      if (result != null) {
        _mentorCourseProvider?.setMentorPartnershipRequest(result);
      }
    });
  }

  bool shouldShowTraining() => _stepsProvider?.getShouldShowAddStep() == true || _quizzesProvider?.getShouldShowQuizzes() == true;  
  
  Future<void> _init() async {
    if (!_isInit && _mentorCourseProvider != null) {
      await Future.wait([
        _mentorCourseProvider!.getCoursesTypes(),
        _mentorCourseProvider!.getCourse(),
        _mentorCourseProvider!.getMentorPartnershipRequest(),
        _mentorCourseProvider!.getMentorWaitingRequest(),
        _goalsProvider!.getGoals(),
        _stepsProvider!.getLastStepAdded(),
        _quizzesProvider!.getQuizzes(),
        _inAppMessagesProvider!.getInAppMessage(),
        _commonProvider!.getAppFlags()
      ]).timeout(const Duration(seconds: 3600));
      _showExpiredMentorPartnershipRequest();
      _showCanceledMentorPartnershipRequest();      
      // await _commonProvider!.initPushNotifications();
      _isInit = true;
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
              shouldReload: false
            )
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
    WidgetsBinding.instance?.addPostFrameCallback(_showInAppMessage);    

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
