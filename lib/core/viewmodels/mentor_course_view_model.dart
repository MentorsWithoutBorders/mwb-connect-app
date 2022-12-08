import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
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
  MentorPartnershipRequestModel? mentorPartnershipRequest;
  CourseModel? course;
  CourseMentor? partnerMentor;
  CourseType? selectedCourseType;
  String errorMessage = '';  
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
    CourseModel course = CourseModel();
    course.mentors = [CourseMentor(meetingUrl: meetingUrl)];
    await _mentorCourseService.addCourse(course);
  }
  
  Future<void> cancelCourse(String? reason) async {
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
          await _mentorCourseService.updateMentorPartnershipRequest(mentorPartnershipRequest?.id, MentorPartnershipRequestModel(wasExpiredShown: true));
        }
        mentorPartnershipRequest = null;
      } else if (mentorPartnershipRequest?.isCanceled != null && mentorPartnershipRequest?.isCanceled == true) {
        if (mentorPartnershipRequest?.wasCanceledShown == null || mentorPartnershipRequest?.wasCanceledShown != null && mentorPartnershipRequest?.wasCanceledShown == false) {
          shouldShowCanceled = true;
          await _mentorCourseService.updateMentorPartnershipRequest(mentorPartnershipRequest?.id, MentorPartnershipRequestModel(wasCanceledShown: true));
        }
        mentorPartnershipRequest = null;
      }
    }
  }

  Future<void> sendMentorPartnershipRequest(MentorPartnershipRequestModel mentorPartnershipRequest) async {
    mentorPartnershipRequest.mentor = (await _userService.getUserDetails()) as CourseMentor;
    mentorPartnershipRequest.courseType = courseType;
    await _mentorCourseService.sendMentorPartnershipRequest(mentorPartnershipRequest);
  } 

  Future<void> acceptMentorPartnershipRequest(String meetingUrl) async {
    await _mentorCourseService.acceptMentorPartnershipRequest(mentorPartnershipRequest?.id, meetingUrl);
    notifyListeners();
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

  Future<CourseMentor> getMentor() async {
    CourseMentor mentor = (await _userService.getUserDetails()) as CourseMentor;
    return mentor;
  }

  CourseMentor getPartnerMentor() {
    String userId = _storageService.userId as String;
    CourseMentor partnerMentor = CourseMentor();
    List<CourseMentor>? mentors = course?.mentors;
    if (mentors != null && mentors.length > 0) {
      for (CourseMentor mentor in mentors) {
        if (mentor.id != userId) {
          partnerMentor = mentor;
          break;
        }
      }
    }
    return partnerMentor;
  }
  
  Subfield getMentorSubfield(CourseMentor mentor) {
    Subfield subfield = Subfield();
    List<Subfield>? subfields = mentor.field?.subfields;
    if (subfields != null && subfields.length > 0) {
      subfield = subfields[0];
    }
    return subfield;
  }

  DateTime getCourseEndDate() {
    return Jiffy(course?.startDateTime).add(months: 3).dateTime;
  }
  
  DateTime getNextLessonDate() {
    DateTime now = DateTime.now();
    Jiffy nextLessonDate = Jiffy(course?.startDateTime);
    while (nextLessonDate.isBefore(now)) {
      nextLessonDate.add(weeks: 1);
    }
    return nextLessonDate.dateTime;
  }  

  void setSelectedCourseType(CourseType? courseType) {
    selectedCourseType = courseType;
    notifyListeners();
  }
  
  void setErrorMessage(String message) {
    errorMessage = message;
  }  
  
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
