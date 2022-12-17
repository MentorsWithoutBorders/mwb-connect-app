import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/string_extension.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_utils_service.dart';

class MentorCourseTextsService {
  final MentorCourseUtilsService _mentorCourseUtilsService = locator<MentorCourseUtilsService>();  

  List<ColoredText> getCourseText(CourseModel? course) {
    if (course == null || course.id == null) {
      return [];
    }
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat monthDayFormat = DateFormat(AppConstants.monthDayFormat, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');      
    CourseMentor mentor = _mentorCourseUtilsService.getMentor(course);
    CourseMentor partnerMentor = _mentorCourseUtilsService.getPartnerMentor(course);
    String mentorOrMentors = 'common.you'.tr().capitalize();
    if (partnerMentor.id != null) {
      mentorOrMentors += ' ' + 'common.and'.tr() + ' ';
      mentorOrMentors += partnerMentor.name as String;
      mentorOrMentors += ' ';
    }
    String courseDuration = course.type?.duration.toString() as String;
    Subfield mentorSubfield = Utils.getMentorSubfield(mentor);
    Subfield partnerMentorSubfield = Utils.getMentorSubfield(partnerMentor);
    String subfieldOrSubfields = mentorSubfield.name!;
    if (partnerMentorSubfield.id != null && mentorSubfield.id != partnerMentorSubfield.id) {
      subfieldOrSubfields = mentorSubfield.name! + ' ' + 'common.and'.tr() + ' ' + partnerMentorSubfield.name!;
    }
    String courseDayOfWeek = dayOfWeekFormat.format(course.startDateTime as DateTime);
    String courseEndDate = monthDayFormat.format(_mentorCourseUtilsService.getCourseEndDate(course));
    String nextLessonDate = dateFormat.format(_mentorCourseUtilsService.getNextLessonDate(course));
    String nextLessonTime = timeFormat.format(course.startDateTime as DateTime);
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String studentPlural = plural('student', course.students?.length as int);        
    String at = 'common.at'.tr();
    String until = 'common.until'.tr();
    String text = 'mentor_course.course_text'.tr(args: [mentorOrMentors, courseDuration, subfieldOrSubfields, courseDayOfWeek, courseEndDate, nextLessonDate, nextLessonTime, timeZone, studentPlural]);
    List<ColoredText> coloredTexts = [
      ColoredText(text: mentorOrMentors, color: partnerMentor.id == null ? AppColors.DOVE_GRAY : AppColors.TANGO),
      ColoredText(text: text.substring(mentorOrMentors.length, text.indexOf(subfieldOrSubfields)), color: AppColors.DOVE_GRAY),
      ColoredText(text: subfieldOrSubfields, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(subfieldOrSubfields) + subfieldOrSubfields.length, text.indexOf(courseDayOfWeek)), color: AppColors.DOVE_GRAY),
      ColoredText(text: courseDayOfWeek, color: AppColors.TANGO),
      ColoredText(text: ' ' + until + ' ', color: AppColors.DOVE_GRAY),
      ColoredText(text: courseEndDate, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(courseEndDate) + courseEndDate.length, text.indexOf(nextLessonDate)), color: AppColors.DOVE_GRAY),
      ColoredText(text: nextLessonDate, color: AppColors.TANGO),
      ColoredText(text: ' ' + at + ' ', color: AppColors.DOVE_GRAY),
      ColoredText(text: nextLessonTime + ' ' + timeZone, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(timeZone) + timeZone.length), color: AppColors.DOVE_GRAY),
    ];
    return coloredTexts;
  }

  String getCancelCourseText(CourseModel? course) {
    if (course == null || course.id == null) {
      return '';
    }    
    String text = 'common.cancel_course_text'.tr();
    CourseMentor partnerMentor = _mentorCourseUtilsService.getPartnerMentor(course);
    if (partnerMentor.id != null) {
      text += ' ' + 'common.cancel_course_partner_text'.tr(args: [partnerMentor.name as String]);
    }
    return text;
  }
  
  List<ColoredText> getWaitingFirstStudentText(CourseModel? course) {
    if (course == null || course.id == null) {
      return [];
    }    
    String minStudentsCourse = AppConstants.minStudentsCourse.toString();
    String maxStudentsCourse = AppConstants.maxStudentsCourse.toString();
    int courseDuration = course.type?.duration as int;
    String text = 'mentor_course.waiting_first_student'.tr(args: [minStudentsCourse, courseDuration.toString(), maxStudentsCourse]);
    List<ColoredText> coloredTexts = [
      ColoredText(text: text.substring(0, text.indexOf(minStudentsCourse)), color:AppColors.DOVE_GRAY),
      ColoredText(text: minStudentsCourse, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(minStudentsCourse) + minStudentsCourse.length, text.indexOf(maxStudentsCourse)), color: AppColors.DOVE_GRAY),
      ColoredText(text: maxStudentsCourse, color: AppColors.TANGO)
    ];
    return coloredTexts;     
  }

  List<ColoredText> getWaitingMoreStudentsText(CourseModel? course) {
    if (course == null || course.id == null) {
      return [];
    }    
    final DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    final DateFormat timeFormat = DateFormat(AppConstants.timeFormat, 'en');
    String minStudentsCourse = AppConstants.minStudentsCourse.toString();
    String maxStudentsCourse = AppConstants.maxStudentsCourse.toString();
    int courseDuration = course.type?.duration as int;
    DateTime courseStartDateTime = course.startDateTime as DateTime;
    String courseDayOfWeek = dayOfWeekFormat.format(courseStartDateTime);
    String courseTime = timeFormat.format(courseStartDateTime);
    DateTime now = DateTime.now();    
    String timeZone = now.timeZoneName;
    String text = 'mentor_course.waiting_more_students'.tr(args: [courseDuration.toString(), minStudentsCourse, courseDayOfWeek, courseTime, timeZone, maxStudentsCourse]);
    String at = 'common.at'.tr();
    List<ColoredText> coloredTexts = [
      ColoredText(text: text.substring(0, text.indexOf(courseDuration.toString())), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDuration.toString(), color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(courseDuration.toString()) + courseDuration.toString().length, text.indexOf(minStudentsCourse)), color:AppColors.DOVE_GRAY),
      ColoredText(text: minStudentsCourse, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(minStudentsCourse.toString()) + minStudentsCourse.toString().length, text.indexOf(courseDayOfWeek)), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDayOfWeek, color: AppColors.TANGO),
      ColoredText(text: ' ' + at + ' ', color: AppColors.DOVE_GRAY),
      ColoredText(text: courseTime + ' ' + timeZone, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(courseTime) + courseTime.length, text.indexOf(maxStudentsCourse)), color: AppColors.DOVE_GRAY),
      ColoredText(text: maxStudentsCourse, color: AppColors.TANGO),
      ColoredText(text: '.', color: AppColors.DOVE_GRAY),
    ];
    return coloredTexts;     
  }
  
  List<ColoredText> getWaitingStudentsPartnerText(CourseModel? course) {
    if (course == null || course.id == null) {
      return [];
    }    
    final DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    final DateFormat timeFormat = DateFormat(AppConstants.timeFormat, 'en');
    String minStudentsCourse = AppConstants.minStudentsCourse.toString();
    String maxStudentsCourse = AppConstants.maxStudentsCourse.toString();
    int courseDuration = course.type?.duration as int;
    DateTime courseStartDateTime = course.startDateTime as DateTime;
    String courseDayOfWeek = dayOfWeekFormat.format(courseStartDateTime);
    String courseTime = timeFormat.format(courseStartDateTime);
    CourseMentor partnerMentor = _mentorCourseUtilsService.getPartnerMentor(course);
    String partnerMentorName = partnerMentor.name as String;
    DateTime now = DateTime.now();    
    String timeZone = now.timeZoneName;
    String text = 'mentor_course.waiting_students_partner'.tr(args: [courseDuration.toString(), partnerMentorName, minStudentsCourse, courseDayOfWeek, courseTime, timeZone, maxStudentsCourse]);
    String at = 'common.at'.tr();
    List<ColoredText> coloredTexts = [
      ColoredText(text: text.substring(0, text.indexOf(courseDuration.toString())), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDuration.toString(), color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(courseDuration.toString()) + courseDuration.toString().length, text.indexOf(partnerMentorName)), color:AppColors.DOVE_GRAY),
      ColoredText(text: partnerMentorName, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(partnerMentorName) + partnerMentorName.length, text.indexOf(minStudentsCourse)), color:AppColors.DOVE_GRAY),
      ColoredText(text: minStudentsCourse, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(minStudentsCourse.toString()) + minStudentsCourse.toString().length, text.indexOf(courseDayOfWeek)), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDayOfWeek, color: AppColors.TANGO),
      ColoredText(text: ' ' + at + ' ', color:AppColors.DOVE_GRAY),
      ColoredText(text: courseTime + ' ' + timeZone, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(courseTime) + courseTime.length, text.indexOf(maxStudentsCourse)), color:AppColors.DOVE_GRAY),
      ColoredText(text: maxStudentsCourse, color: AppColors.TANGO),
      ColoredText(text: '.', color:AppColors.DOVE_GRAY),
    ];
    return coloredTexts;     
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
    List<ColoredText> coloredTexts = [
      ColoredText(text: text + ': ', color:AppColors.DOVE_GRAY),
      ColoredText(text: studentsCount.toString(), color: AppColors.TANGO),

    ];
    return coloredTexts;     
  }
  
  List<ColoredText> getMentorPartnershipText(MentorPartnershipRequestModel? mentorPartnershipRequest) {
    if (mentorPartnershipRequest == null || mentorPartnershipRequest.id == null) {
      return [];
    }    
    CourseMentor mentor = mentorPartnershipRequest.mentor as CourseMentor;
    CourseMentor partnerMentor = mentorPartnershipRequest.partnerMentor as CourseMentor;
    String courseDayOfWeek = mentorPartnershipRequest.courseDayOfWeek as String;
    String courseStartTime = mentorPartnershipRequest.courseStartTime as String;
    String courseDuration = mentorPartnershipRequest.courseType?.duration.toString() as String;
    String partnerMentorName = partnerMentor.name as String;
    Subfield mentorSubfield = Utils.getMentorSubfield(mentor);
    Subfield partnerMentorSubfield = Utils.getMentorSubfield(partnerMentor);
    String subfieldOrSubfields = mentorSubfield.name!;
    if (partnerMentorSubfield.id != null && mentorSubfield.id != partnerMentorSubfield.id) {
      subfieldOrSubfields = mentorSubfield.name! + ' ' + 'common.and'.tr() + ' ' + partnerMentorSubfield.name!;
    }
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String text = 'mentor_course.mentor_partnership_request_text'.tr(args: [partnerMentorName, courseDuration, subfieldOrSubfields, courseDayOfWeek, courseStartTime, timeZone]);
    List<ColoredText> coloredTexts = [
      ColoredText(text: partnerMentorName, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(partnerMentorName) + partnerMentorName.length, text.indexOf(courseDuration)), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDuration, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(courseDuration) + courseDuration.length, text.indexOf(subfieldOrSubfields)), color:AppColors.DOVE_GRAY),
      ColoredText(text: subfieldOrSubfields, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(subfieldOrSubfields) + subfieldOrSubfields.length, text.indexOf(courseDayOfWeek)), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDayOfWeek, color: AppColors.TANGO),
      ColoredText(text: ' ' + at + ' ', color:AppColors.DOVE_GRAY),
      ColoredText(text: courseStartTime + ' ' + timeZone, color: AppColors.TANGO),
      ColoredText(text: '.', color:AppColors.DOVE_GRAY)
    ];
    return coloredTexts;     
  }

  List<ColoredText> getMentorPartnershipBottomText(MentorPartnershipRequestModel? mentorPartnershipRequest) {
    if (mentorPartnershipRequest == null || mentorPartnershipRequest.id == null) {
      return [];
    }    
    DateTime sentDateTime = mentorPartnershipRequest.sentDateTime as DateTime;
    CourseMentor partnerMentor = mentorPartnershipRequest.partnerMentor as CourseMentor;
    String partnerMentorName = partnerMentor.name as String;
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    String date = dateFormat.format(sentDateTime.add(Duration(days: 1)));
    String text = 'mentor_course.mentor_partnership_request_bottom_text'.tr(args: [date, partnerMentorName]);
    List<ColoredText> coloredTexts = [
      ColoredText(text: text.substring(0, text.indexOf(date)), color:AppColors.DOVE_GRAY),
      ColoredText(text: date, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(date) + date.length, text.indexOf(partnerMentorName)), color:AppColors.DOVE_GRAY),
      ColoredText(text: partnerMentorName, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(partnerMentorName) + partnerMentorName.length), color:AppColors.DOVE_GRAY),
    ];
    return coloredTexts;     
  }
  
  List<ColoredText> getRejectMentorPartnershipText(MentorPartnershipRequestModel? mentorPartnershipRequest) {
    if (mentorPartnershipRequest == null || mentorPartnershipRequest.id == null) {
      return [];
    }      
    CourseMentor mentor = mentorPartnershipRequest.mentor as CourseMentor;
    CourseMentor partnerMentor = mentorPartnershipRequest.partnerMentor as CourseMentor;
    String courseDayOfWeek = mentorPartnershipRequest.courseDayOfWeek as String;
    String courseStartTime = mentorPartnershipRequest.courseStartTime as String;
    String courseDuration = mentorPartnershipRequest.courseType?.duration.toString() as String;
    String partnerMentorName = partnerMentor.name as String;
    Subfield mentorSubfield = Utils.getMentorSubfield(mentor);
    Subfield partnerMentorSubfield = Utils.getMentorSubfield(partnerMentor);
    String subfieldOrSubfields = mentorSubfield.name!;
    if (partnerMentorSubfield.id != null && mentorSubfield.id != partnerMentorSubfield.id) {
      subfieldOrSubfields = mentorSubfield.name! + ' ' + 'common.and'.tr() + ' ' + partnerMentorSubfield.name!;
    }
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String text = 'mentor_course.reject_mentor_partnership_request_text'.tr(args: [partnerMentorName, courseDuration, subfieldOrSubfields, courseDayOfWeek, courseStartTime, timeZone]);
    List<ColoredText> coloredTexts = [
      ColoredText(text: text.substring(0, text.indexOf(partnerMentorName)), color:AppColors.DOVE_GRAY),
      ColoredText(text: partnerMentorName, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(partnerMentorName) + partnerMentorName.length, text.indexOf(courseDuration)), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDuration, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(courseDuration) + courseDuration.length, text.indexOf(subfieldOrSubfields)), color:AppColors.DOVE_GRAY),
      ColoredText(text: subfieldOrSubfields, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(subfieldOrSubfields) + subfieldOrSubfields.length, text.indexOf(courseDayOfWeek)), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDayOfWeek, color: AppColors.TANGO),
      ColoredText(text: ' ' + at + ' ', color:AppColors.DOVE_GRAY),
      ColoredText(text: courseStartTime + ' ' + timeZone, color: AppColors.TANGO),
      ColoredText(text: '.', color:AppColors.DOVE_GRAY)
    ];
    return coloredTexts;     
  }
  
  List<ColoredText> getWaitingMentorPartnershipApprovalText(MentorPartnershipRequestModel? mentorPartnershipRequest) {
    if (mentorPartnershipRequest == null || mentorPartnershipRequest.id == null) {
      return [];
    }    
    CourseMentor mentor = mentorPartnershipRequest.mentor as CourseMentor;
    CourseMentor partnerMentor = mentorPartnershipRequest.partnerMentor as CourseMentor;
    String courseDayOfWeek = mentorPartnershipRequest.courseDayOfWeek as String;
    String courseStartTime = mentorPartnershipRequest.courseStartTime as String;
    String courseDuration = mentorPartnershipRequest.courseType?.duration.toString() as String;
    String partnerMentorName = partnerMentor.name as String;
    Subfield mentorSubfield = Utils.getMentorSubfield(mentor);
    Subfield partnerMentorSubfield = Utils.getMentorSubfield(partnerMentor);
    String subfieldOrSubfields = mentorSubfield.name!;
    if (partnerMentorSubfield.id != null && mentorSubfield.id != partnerMentorSubfield.id) {
      subfieldOrSubfields = mentorSubfield.name! + ' ' + 'common.and'.tr() + ' ' + partnerMentorSubfield.name!;
    }
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String text = 'mentor_course.waiting_mentor_partnership_text'.tr(args: [partnerMentorName, courseDuration, subfieldOrSubfields, courseDayOfWeek, courseStartTime, timeZone]);
    List<ColoredText> coloredTexts = [
      ColoredText(text: text.substring(0, text.indexOf(partnerMentorName)), color:AppColors.DOVE_GRAY),
      ColoredText(text: partnerMentorName, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(partnerMentorName) + partnerMentorName.length, text.indexOf(courseDuration)), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDuration, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(courseDuration) + courseDuration.length, text.indexOf(subfieldOrSubfields)), color:AppColors.DOVE_GRAY),
      ColoredText(text: subfieldOrSubfields, color: AppColors.TANGO),
      ColoredText(text: text.substring(text.indexOf(subfieldOrSubfields) + subfieldOrSubfields.length, text.indexOf(courseDayOfWeek)), color:AppColors.DOVE_GRAY),
      ColoredText(text: courseDayOfWeek, color: AppColors.TANGO),
      ColoredText(text: ' ' + at + ' ', color:AppColors.DOVE_GRAY),
      ColoredText(text: courseStartTime + ' ' + timeZone, color: AppColors.TANGO),
      ColoredText(text: '.', color:AppColors.DOVE_GRAY)
    ];
    return coloredTexts;     
  }
}