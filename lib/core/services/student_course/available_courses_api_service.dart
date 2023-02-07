import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class AvailableCoursesApiService {
  final ApiService _api = locator<ApiService>();

  Future<List<Field>> getFields() async {
    dynamic response = await _api.getHTTP(url: '/courses/fields');
    List<Field> fields = [];
    if (response != null) {
      fields = List<Field>.from(response.map((model) => Field.fromJson(model)));
    }
    return fields;
  }   

  Future<List<CourseModel>> getAvailableCourses(String? fieldId) async {
    dynamic response = await _api.getHTTP(url: '/courses');
    List<CourseModel> availableCourses = [];
    if (response != null) {
      availableCourses = List<CourseModel>.from(response.map((model) => CourseModel.fromJson(model)));
    }
    return availableCourses;
  }

  Future<CourseModel> joinCourse(String? id) async {
    await _api.putHTTP(url: '/courses/$id/join');  
    Map<String, dynamic> response = await _api.putHTTP(url: '/courses/$id/join');
    CourseModel course = CourseModel.fromJson(response); 
    return course;
  } 
}