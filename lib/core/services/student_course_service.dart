import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/in_app_message_model.dart';

class StudentCourseService {
  final ApiService _api = locator<ApiService>();

  Future<List<CourseModel>> getAvailableCourses(String? fieldId) async {
    dynamic response = await _api.getHTTP(url: '/courses');
    List<CourseModel> availableCourses = [];
    if (response != null) {
      availableCourses = List<CourseModel>.from(response.map((model) => CourseModel.fromJson(model)));
    }
    return availableCourses;
  }

  Future<CourseModel> getCourse() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/courses/current');
    CourseModel course = CourseModel.fromJson(response);
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

  Future<List<Field>> getFields() async {
    dynamic response = await _api.getHTTP(url: '/available_courses/fields');
    List<Field> fields = [];
    if (response != null) {
      fields = List<Field>.from(response.map((model) => Field.fromJson(model)));
    }
    return fields;
  }  
}