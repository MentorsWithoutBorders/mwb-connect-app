import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/next_lesson_student_model.dart';
import 'package:mwb_connect_app/core/models/attached_message_model.dart';
import 'package:mwb_connect_app/core/models/student_certificate.model.dart';

class StudentCourseApiService {
  final ApiService _api = locator<ApiService>();

  Future<CourseModel> getCourse() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/current');
    CourseModel course = CourseModel.fromJson(response);
    return course;
  }

  Future<NextLessonStudent> getNextLesson() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/next_lesson');
    NextLessonStudent nextLesson = NextLessonStudent.fromJson(response);
    return nextLesson;
  }    

  Future<String?> getCourseNotes(String? id) async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/$id/notes');
    CourseModel course = CourseModel.fromJson(response);
    return course.notes;
  }

  Future<void> cancelCourse(String? id, String? reason) async {
    AttachedMessage attachedMessage = AttachedMessage(
      text: reason
    );
    await _api.putHTTP(url: '/courses/$id/cancel', data: attachedMessage.toJson());  
    return ;
  }

  Future<NextLessonStudent> cancelNextLesson(String? courseId, String? reason) async {
    AttachedMessage attachedMessage = AttachedMessage(
      text: reason
    );
    Map<String, dynamic> response = await _api.putHTTP(url: '/courses/$courseId/cancel_next_lesson', data: attachedMessage.toJson());  
    NextLessonStudent nextLesson = NextLessonStudent.fromJson(response);
    return nextLesson;
  }    
  
  Future<StudentCertificate> getCertificateSent() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/admin/students_certificates/certificate_sent');
    return StudentCertificate.fromJson(response);
  }   
}