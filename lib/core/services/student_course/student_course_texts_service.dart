import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/next_lesson_student_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_utils_service.dart';

class StudentCourseTextsService {
  final StudentCourseUtilsService _studentCourseUtilsService = locator<StudentCourseUtilsService>();

  List<ColoredText> getCourseText(CourseModel? course, NextLessonStudent? nextLesson) {
    if (course == null || course.id == null || nextLesson?.lessonDateTime == null) {
      return [];
    }    
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat monthDayFormat = DateFormat(AppConstants.monthDayFormat, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');    
    String courseDuration = course.type?.duration.toString() as String;
    CourseMentor mentor = course.mentors?[0] as CourseMentor;
    CourseMentor? partnerMentor = course.mentors!.length > 1 ? course.mentors![1] : null;
    String mentorsSubfields = _studentCourseUtilsService.getMentorsSubfieldsNames(course.mentors);
    String mentorsNames = _studentCourseUtilsService.getMentorsNames(course.mentors);
    String courseDayOfWeek = dayOfWeekFormat.format(course.startDateTime as DateTime);
    String courseEndDate = monthDayFormat.format(course.endDateTime as DateTime);
    String nextLessonDate = dateFormat.format(nextLesson?.lessonDateTime as DateTime);
    String nextLessonTime = timeFormat.format(nextLesson?.lessonDateTime as DateTime);
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String until = 'common.until'.tr();
    String at = 'common.at'.tr();
    String text = 'student_course.course_text'.tr(args: [courseDuration, mentorsSubfields, mentorsNames, courseDayOfWeek, courseEndDate, nextLessonDate, nextLessonTime, timeZone]);
    String courseLinkText = 'student_course.course_link_text'.tr();
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
      ColoredText(text: ' ' + until + ' ', color: AppColors.DOVE_GRAY),
      ColoredText(text: courseEndDate, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(courseEndDate) + courseEndDate.length, text.indexOf(nextLessonDate)), color: AppColors.DOVE_GRAY),
      ColoredText(text: nextLessonDate, color: AppColors.TANGO),
      ColoredText(text: ' ' + at + ' ', color: AppColors.DOVE_GRAY),
      ColoredText(text: nextLessonTime + ' ' + timeZone, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(timeZone) + timeZone.length), color: AppColors.DOVE_GRAY),
      ColoredText(text: ' ' + courseLinkText, color: AppColors.DOVE_GRAY),
    ];
  }

  List<ColoredText> getWaitingStartCourseText(CourseModel? course) {
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
    String text = 'student_course.waiting_course_text'.tr(args: [courseDuration, mentorsSubfields, mentorsNames, courseDayOfWeek, courseTime, timeZone]);
    String courseStartText = 'common.start_course_text'.tr(args:[AppConstants.minStudentsCourse.toString()]);
    courseStartText = courseStartText[0].toUpperCase() + courseStartText.substring(1) + '.';
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
      ColoredText(text: text.substring(text.indexOf(timeZone) + timeZone.length), color: AppColors.DOVE_GRAY),
      ColoredText(text: ' ' + courseStartText, color: AppColors.DOVE_GRAY),
    ];
  }
  
  List<ColoredText> getCurrentStudentsText(CourseModel? course) {
    if (course == null || course.id == null) {
      return [];
    }    
    int studentsCount = 0;
    final List<CourseStudent>? students = course.students;
    if (students != null) {
      studentsCount = students.length;
    }      
    String text = 'common.current_number_students'.tr();
    return [
      ColoredText(text: text + ': ', color: AppColors.DOVE_GRAY),
      ColoredText(text: studentsCount.toString(), color: AppColors.TANGO)
    ];
  }   
}
