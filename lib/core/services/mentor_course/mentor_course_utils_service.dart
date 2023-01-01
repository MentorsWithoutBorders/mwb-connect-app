import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class MentorCourseUtilsService {
  final LocalStorageService _storageService = locator<LocalStorageService>();

  bool shouldShowTrainingCompleted() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    return Utils.getDSTAdjustedDifferenceInDays(now, registeredOn) <= 7 * AppConstants.mentorWeeksTraining;
  }  

  CourseMentor getMentor(CourseModel? course) {
    String userId = _storageService.userId as String;
    List<CourseMentor>? mentors = course?.mentors;
    if (mentors != null) {
      for (CourseMentor mentor in mentors) {
        if (mentor.id == userId) {
          return mentor;
        }
      }
    }
    return CourseMentor();
  }     

  CourseMentor getPartnerMentor(CourseModel? course) {
    String userId = _storageService.userId as String;
    List<CourseMentor>? mentors = course?.mentors;
    if (mentors != null) {
      for (CourseMentor mentor in mentors) {
        if (mentor.id != userId) {
          return mentor;
        }
      }
    }
    return CourseMentor();
  }

  DateTime getCourseEndDate(CourseModel? course) {
    int duration = course?.type?.duration as int;
    int weeks = duration == 3 ? 13 : 26;
    return Jiffy(course?.startDateTime).add(weeks: weeks).dateTime;
  }
  
  DateTime getNextLessonDate(CourseModel? course) {
    DateTime now = DateTime.now();
    Jiffy nextLessonDate = Jiffy(course?.startDateTime);
    while (nextLessonDate.isBefore(now)) {
      nextLessonDate.add(weeks: 1);
    }
    return nextLessonDate.dateTime;
  }
  
  DateTime getCourseDateTime(String dayOfWeek, String timeFrom) {
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateTime dateTime = DateTime.now();
    while (dayOfWeek != dayOfWeekFormat.format(dateTime)) {
      dateTime = dateTime.add(Duration(days: 1));
    }
    List<int> timeFromArray = Utils.convertTime12to24(timeFrom);
    dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, timeFromArray[0], timeFromArray[1]);
    return dateTime;
  }

  String getMeetingUrl(CourseModel? course) {
    CourseMentor mentor = getMentor(course);
    return mentor.meetingUrl ?? '';
  }

  CourseModel? getUpdatedMeetingUrl(CourseModel? course, String meetingUrl) {
    CourseMentor mentor = getMentor(course);
    mentor.meetingUrl = meetingUrl;
    List<CourseMentor>? mentors = course?.mentors;
    if (mentors != null) {
      for (int i = 0; i < mentors.length; i++) {
        if (mentors[i].id == mentor.id) {
          mentors[i] = mentor;
          break;
        }
      }
    }
    course?.mentors = mentors;
    return course;
  }
  

  int getMentorsCount(CourseModel? course) {
    return course?.mentors?.length ?? 0;
  }
  
  int getStudentsCount(CourseModel? course) {
    return course?.students?.length ?? 0;
  }
}