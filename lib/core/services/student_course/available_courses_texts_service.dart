import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_utils_service.dart';

class AvailableCoursesTextsService {
  final StudentCourseUtilsService _studentCourseUtilsService = locator<StudentCourseUtilsService>();

  String getCourseTypeText(CourseModel course) {
    String courseType = '';
    if (course.type != null) {
      courseType = course.type?.duration.toString() as String;
      courseType += '-' + plural('month', 1) + ' ' + plural('course', 1);
      courseType = '(' + courseType + ')';
    }
    return courseType;
  }  
  
  String getCourseScheduleText(CourseModel? course) {
    if (course?.startDateTime == null) {
      return '';
    }
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');  
    String courseDayOfWeek = dayOfWeekFormat.format(course?.startDateTime as DateTime);
    String courseTime = timeFormat.format(course?.startDateTime as DateTime);
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String courseSchedule = plural(courseDayOfWeek, 2) + ' ' + 'common.at'.tr() + ' ' + courseTime + ' ' + timeZone;
    return courseSchedule;
  }

  List<ColoredText> getJoinCourseText(CourseModel? course) {
    if (course == null || course.id == null) {
      return [];
    }
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');
    String courseDuration = course.type?.duration.toString() as String;
    CourseMentor mentor = course.mentors?[0] as CourseMentor;
    CourseMentor? partnerMentor = course.mentors!.length > 1 ? course.mentors![1] : null;
    String mentorsSubfields = _studentCourseUtilsService.getMentorsSubfieldsNames(course.mentors);
    String mentorsNames = _studentCourseUtilsService.getMentorsNames(course.mentors);
    String courseDayOfWeek = dayOfWeekFormat.format(course.startDateTime as DateTime);
    String courseTime = timeFormat.format(course.startDateTime as DateTime);
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String text = 'student_course.join_course_confirmation_text'.tr(args: [courseDuration, mentorsSubfields, mentorsNames, courseDayOfWeek, courseTime, timeZone]);
    String courseStartText = 'common.start_course_text'.tr(args:[AppConstants.minStudentsCourse.toString()]);
    return [
      ColoredText(text: text.substring(0, text.indexOf(mentorsSubfields)), color: AppColors.DOVE_GRAY),
      ColoredText(text: mentor.field!.subfields![0].name, color: AppColors.TANGO),
      if (partnerMentor != null) ColoredText(text: ' ' + 'common.and'.tr() + ' ', color: AppColors.DOVE_GRAY),
      if (partnerMentor != null) ColoredText(text: partnerMentor.field!.subfields![0].name, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(mentorsSubfields) + mentorsSubfields.length, text.indexOf(mentorsNames)), color: AppColors.DOVE_GRAY),
      ColoredText(text: mentor.name, color: AppColors.TANGO),
      if (partnerMentor != null) ColoredText(text: ' ' + 'common.and'.tr() + ' ', color: AppColors.DOVE_GRAY),
      if (partnerMentor != null) ColoredText(text: partnerMentor.name, color: AppColors.TANGO),  
      ColoredText(text: text.substring(text.indexOf(mentorsNames) + mentorsNames.length, text.indexOf(courseDayOfWeek)), color: AppColors.DOVE_GRAY),
      ColoredText(text: courseDayOfWeek, color: AppColors.TANGO),
      ColoredText(text: ' ' + at + ' ', color: AppColors.DOVE_GRAY),
      ColoredText(text: courseTime + ' ' + timeZone, color: AppColors.TANGO),
      ColoredText(text: '? ' + '(' + courseStartText + ')', color: AppColors.DOVE_GRAY)
    ];
  }
}
