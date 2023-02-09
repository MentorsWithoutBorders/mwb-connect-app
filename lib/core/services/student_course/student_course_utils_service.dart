import 'package:easy_localization/easy_localization.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';

class StudentCourseUtilsService {

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
}
