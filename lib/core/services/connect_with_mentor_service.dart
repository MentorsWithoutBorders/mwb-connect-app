import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_request_result_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/student_certificate.model.dart';

class ConnectWithMentorService {
  final ApiService _api = locator<ApiService>();

  Future<LessonRequestModel> getLessonRequest() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/lesson_request');
    return LessonRequestModel.fromJson(response);
  }

  Future<LessonRequestModel> sendLessonRequest() async {
    Map<String, dynamic> response = await _api.postHTTP(url: '/lesson_requests', data: {});
    return LessonRequestModel.fromJson(response);
  }

  Future<LessonRequestResult> sendCustomLessonRequest(User? user) async {
    Map<String, dynamic> response = await _api.postHTTP(url: '/lesson_requests/send_custom_lesson_request', data: user?.toJson());
    LessonRequestResult lessonRequestResult = LessonRequestResult.fromJson(response);
    return lessonRequestResult;    
  }    
  
  Future<void> cancelLessonRequest(String? id) async {
    await _api.putHTTP(url: '/lesson_requests/$id/cancel_lesson_request', data: {});  
    return ;
  }  
  
  Future<Lesson> getNextLesson() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/next_lesson');
    return Lesson.fromJson(response);
  }   

  Future<void> cancelNextLesson(Lesson? lesson, bool? isSingleLesson) async {
    Map<String, Object?> data = {};
    Lesson lessonData = Lesson(mentor: User(id: lesson?.mentor?.id), isRecurrent: lesson?.isRecurrent);
    if (isSingleLesson == true && lesson?.isRecurrent == true) {
      lessonData.dateTime = lesson?.dateTime;
    }
    data = lessonData.toJson();
    String? id = lesson?.id;    
    await _api.putHTTP(url: '/lessons/$id/cancel_lesson', data: data);  
    return ;
  }

  Future<Lesson> getPreviousLesson() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/previous_lesson');
    return Lesson.fromJson(response);
  }

  Future<StudentCertificate> getCertificateSent() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/admin/students_certificates/certificate_sent');
    return StudentCertificate.fromJson(response);
  }  
}