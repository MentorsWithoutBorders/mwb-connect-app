import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/in_app_message_model.dart';
import 'package:mwb_connect_app/core/models/student_certificate.model.dart';

class StudentCourseApiService {
  final ApiService _api = locator<ApiService>();

  Future<CourseModel> getCourse() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/current');
    CourseModel course = CourseModel.fromJson(response);
    return course;
  }

  Future<String?> getCourseNotes(String? id) async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/$id/notes');
    CourseModel course = CourseModel.fromJson(response);
    return course.notes;
  }

  Future<void> cancelCourse(String? id, String? reason) async {
    InAppMessage inAppMessage = InAppMessage(
      text: reason
    );
    await _api.putHTTP(url: '/courses/$id/cancel', data: inAppMessage.toJson());  
    return ;
  }
  
  Future<StudentCertificate> getCertificateSent() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/admin/students_certificates/certificate_sent');
    return StudentCertificate.fromJson(response);
  }   
}