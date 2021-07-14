import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';

class QuizzesService {
  final ApiService _api = locator<ApiService>();

  Future<int> getQuizNumber() async {
    http.Response response = await _api.getHTTP(url: '/quiz_number');
    return int.parse(response.body);
  }

  Future<int> addQuiz(Quiz quiz) async {
    http.Response response = await _api.postHTTP(url: '/quizzes', data: quiz.toJson());
    return int.parse(response.body);
  }
}