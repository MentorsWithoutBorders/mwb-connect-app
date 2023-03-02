import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';

class RootService {
  final ApiService _api = locator<ApiService>();
  
  Future<Lesson> getNextLesson() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/next_lesson');
    return Lesson.fromJson(response);
  }
}