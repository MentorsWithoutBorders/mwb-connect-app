import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class MentorCourseViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final UserService _userService = locator<UserService>();
  final MentorCourseService _mentorCourseService = locator<MentorCourseService>();
  final LoggerService _loggerService = locator<LoggerService>();  
  List<CourseType> coursesTypes = [];
  CourseType? courseType;
  MentorWaitingRequest? mentorWaitingRequest;
  List<MentorWaitingRequest> mentorsWaitingRequests = [];
  MentorPartnershipRequest? mentorPartnershipRequest;
  Course? course;
  CourseMentor? partnerMentor;
  bool _shouldUnfocus = false;
  bool shouldShowExpired = false;
  bool shouldShowCanceled = false;

  Future<void> getCoursesTypes() async {
    coursesTypes = await _mentorCourseService.getCoursesTypes();
    notifyListeners();
  }
  
  Future<void> getCurrentCourse() async {
    course = await _mentorCourseService.getCurrentCourse();
    notifyListeners();
  }
  
  Future<void> addCourse(String meetingUrl) async {
    Course course = Course();
    course.mentors = [CourseMentor(meetingUrl: meetingUrl)];
    await _mentorCourseService.addCourse(course);
  }
  
  Future<void> cancelCourse(String reason) async {
    await _mentorCourseService.cancelCourse(course?.id, reason);
  }  

  Future<void> getMentorsWaitingRequests() async {
    mentorsWaitingRequests = await _mentorCourseService.getMentorsWaitingRequests();
    notifyListeners();
  }
  
  Future<void> getCurrentMentorWaitingRequest() async {
    mentorWaitingRequest = await _mentorCourseService.getCurrentMentorWaitingRequest();
    notifyListeners();
  }

  Future<void> addMentorWaitingRequest(MentorWaitingRequest mentorWaitingRequest) async {
    mentorWaitingRequest.courseType = courseType;
    await _mentorCourseService.addMentorWaitingRequest(mentorWaitingRequest);
  }
  
  Future<void> cancelMentorWaitingpRequest() async {
    await _mentorCourseService.cancelMentorWaitingRequest(mentorWaitingRequest?.id);
    notifyListeners();
  }

  Future<void> getCurrentMentorPartnershipRequest() async {
    mentorPartnershipRequest = await _mentorCourseService.getCurrentMentorPartnershipRequest();
    if (mentorPartnershipRequest != null && mentorPartnershipRequest?.id != null) {
      if (mentorPartnershipRequest?.isExpired != null && mentorPartnershipRequest?.isExpired == true) {
        if (mentorPartnershipRequest?.wasExpiredShown == null || mentorPartnershipRequest?.wasExpiredShown != null && mentorPartnershipRequest?.wasExpiredShown == false) {
          shouldShowExpired = true;
          await _mentorCourseService.updateMentorPartnershipRequest(mentorPartnershipRequest?.id, MentorPartnershipRequest(wasExpiredShown: true));
        }
        mentorPartnershipRequest = null;
      } else if (mentorPartnershipRequest?.isCanceled != null && mentorPartnershipRequest?.isCanceled == true) {
        if (mentorPartnershipRequest?.wasCanceledShown == null || mentorPartnershipRequest?.wasCanceledShown != null && mentorPartnershipRequest?.wasCanceledShown == false) {
          shouldShowCanceled = true;
          await _mentorCourseService.updateMentorPartnershipRequest(mentorPartnershipRequest?.id, MentorPartnershipRequest(wasCanceledShown: true));
        }
        mentorPartnershipRequest = null;
      }
    }
  }

  Future<void> sendMentorPartnershipRequest(MentorPartnershipRequest mentorPartnershipRequest) async {
    mentorPartnershipRequest.mentor = (await _userService.getUserDetails()) as CourseMentor;
    mentorPartnershipRequest.courseType = courseType;
    await _mentorCourseService.sendMentorPartnershipRequest(mentorPartnershipRequest);
  }

  Future<void> acceptMentorPartnershipRequest(String meetingUrl) async {
    await _mentorCourseService.acceptMentorPartnershipRequest(mentorPartnershipRequest?.id, meetingUrl);
  }

  Future<void> rejectMentorPartnershipRequest(String? reason) async {
    await _mentorCourseService.rejectMentorPartnershipRequest(mentorPartnershipRequest?.id, reason);
    mentorPartnershipRequest?.isRejected = true;
    notifyListeners();
  }

  Future<void> cancelMentorPartnershipRequest() async {
    await _mentorCourseService.cancelMentorPartnershipRequest(mentorPartnershipRequest?.id);
    mentorPartnershipRequest?.isCanceled = true;
    notifyListeners();
  }

  bool get isCourse => course != null && course?.id != null && course?.isCanceled != true;
  
  bool get isMentorPartnershipRequest => !isCourse && mentorPartnershipRequest != null && mentorPartnershipRequest?.id != null && mentorPartnershipRequest?.isRejected != true;
  
  bool checkValidUrl(String url) {
    return Uri.parse(url).host.isNotEmpty && (url.contains('meet') || url.contains('zoom'));
  }

  bool shouldShowTrainingCompleted() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    return Utils.getDSTAdjustedDifferenceInDays(now, registeredOn) <= 7 * AppConstants.mentorWeeksTraining;
  }

  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }

  void addLogEntry(String text) {
    _loggerService.addLogEntry(text);
  }  
}
