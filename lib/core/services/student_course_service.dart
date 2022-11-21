import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/in_app_message_model.dart';

class StudentCourseService {
  final ApiService _api = locator<ApiService>();

  Future<List<Course>> getAvailableCourses() async {
    dynamic response = await _api.getHTTP(url: '/courses');
    List<Course> availableCourses = [];
    if (response != null) {
      availableCourses = List<Course>.from(response.map((model) => Course.fromJson(model)));
    }
    return availableCourses;
  }

  Future<Course> getCurrentCourse() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/current');
    Course course = Course.fromJson(response);
    return course;
  }

  Future<void> joinCourse(String? id) async {
    await _api.putHTTP(url: '/courses/$id/join', data: {});  
    return ;
  }

  Future<void> cancelCourse(String? id, String? reason) async {
    InAppMessage inAppMessage = InAppMessage(
      text: reason
    );
    await _api.putHTTP(url: '/courses/$id/cancel', data: inAppMessage.toJson());  
    return ;
  }
}