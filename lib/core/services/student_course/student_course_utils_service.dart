import 'package:easy_localization/easy_localization.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class StudentCourseUtilsService {
  final LocalStorageService _storageService = locator<LocalStorageService>();  
  final LoggerService _loggerService = locator<LoggerService>();

  CourseMentor getMentor(CourseModel? course) {
    List<CourseMentor>? mentors = course?.mentors;
    if (mentors != null && mentors.isNotEmpty) {
      return mentors[0];
    }
    return CourseMentor();
  }

  CourseMentor getPartnerMentor(CourseModel? course) {
    List<CourseMentor>? mentors = course?.mentors;
    if (mentors != null && mentors.isNotEmpty && mentors.length > 1) {
      return mentors[1];
    }
    return CourseMentor();
  } 

  String getMentorsNames(CourseModel? course) {
    if (course == null || course.mentors == null || course.mentors!.isEmpty) {
      return '';
    }
    CourseMentor mentor = course.mentors?[0] as CourseMentor;
    CourseMentor? partnerMentor = course.mentors!.length > 1 ? course.mentors![1] : null;
    String mentorsNames = '';
    if (partnerMentor != null) {
      mentorsNames = mentor.name! + ' ' + 'common.and'.tr() + ' ' + partnerMentor.name!;
    } else {
      mentorsNames = mentor.name!;
    }
    return mentorsNames;
  }

  String getMentorsSubfieldsNames(CourseModel course) {
    if (course.mentors == null || course.mentors!.isEmpty) {
      return '';
    }    
    CourseMentor mentor = course.mentors?[0] as CourseMentor;
    CourseMentor? partnerMentor = course.mentors!.length > 1 ? course.mentors![1] : null;
    String mentorsSubfields = '';
    if (partnerMentor != null) {
      mentorsSubfields = mentor.field!.subfields![0].name! + ' ' + 'common.and'.tr() + ' ' + partnerMentor.field!.subfields![0].name!;
    } else {
      mentorsSubfields = mentor.field!.subfields![0].name!;
    }
    return mentorsSubfields;
  }

  DateTime getCourseEndDate(CourseModel course) {
    Jiffy courseEndDate = Jiffy(course.startDateTime);
    courseEndDate.add(months: 3);
    while (courseEndDate.format('EEEE') != Jiffy(course.startDateTime).format('EEEE')) {
      courseEndDate.add(days: 1);
    }
    return courseEndDate.dateTime;
  }
  
  DateTime getNextLessonDate(CourseModel course) {
    DateTime now = DateTime.now();
    Jiffy nextLessonDate = Jiffy(course.startDateTime);
    while (nextLessonDate.isBefore(now)) {
      nextLessonDate.add(weeks: 1);
    }
    return nextLessonDate.dateTime;
  }

  DateTime? getCertificateDate() {
    DateTime date = DateTime.now();
    if (_storageService.registeredOn != null) {
      DateTime registeredOn = DateTime.parse(_storageService.registeredOn as String);
      date = Jiffy(registeredOn).add(months: 3).dateTime;
    }
    return date;
  }
  
  bool shouldShowTrainingCompleted() {
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    return Utils.getDSTAdjustedDifferenceInDays(now, registeredOn) <= 7 * (AppConstants.studentWeeksTraining + 7);
  }  

  bool getShouldShowProductivityReminder() {
    DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');    
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = DateTime.parse(_storageService.registeredOn as String);
    return Utils.getDSTAdjustedDifferenceInDays(now, registeredOn) > 14 && _storageService.lastProductivityReminderShownDate != dateFormat.format(now);
  }

  void setLastShownProductivityReminderDate() {
    DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');
    String today = dateFormat.format(DateTime.now());
    _storageService.lastProductivityReminderShownDate = today;
  }  
  
  List<String> getLogsList(String? selectedGoalId, String? lastStepAddedId, List<Quiz>? quizzes, CourseModel? course) {
    String goalText = 'goal: ';
    if (selectedGoalId != null) {
      goalText += selectedGoalId;
    } else {
      goalText += 'null';
    }
    String lastStepAddedText = 'last step added: ';
    if (lastStepAddedId != null) {
      lastStepAddedText += lastStepAddedId;
    } else {
      lastStepAddedText += 'null';
    }
    String quizzesText = 'quizzes: ';
    if (quizzes != null) {
      for (Quiz quiz in quizzes) {
        if (quiz.isCorrect == true) {
          quizzesText += quiz.number.toString() + ', ';
        }
      }
      if (quizzesText.contains(',')) {
        quizzesText = quizzesText.substring(0, quizzesText.length - 2);
      }
    } else {
      quizzesText += '[]';
    }
    String courseText = 'course: ';
    if (course?.id != null) {
      courseText += course?.id as String;
    } else {
      courseText += 'null';
    }
 
    return [
      goalText,
      lastStepAddedText,
      quizzesText,
      courseText,
    ];
  }
  
  void sendAPIDataLogs(int i, String error, List<String> logs) {
    String attemptText = 'connect_with_mentor_view attempt ' + i.toString();
    if (error != '') {
      attemptText += ', error: ' + error;
    }
    attemptText += '\n';
    for (String log in logs) {
      attemptText += log + '\n';
    }
    _loggerService.addLogEntry(attemptText);
  }    
}
