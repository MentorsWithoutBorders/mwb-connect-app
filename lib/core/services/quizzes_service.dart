import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';

class QuizzesService {
  final ApiService _api = locator<ApiService>();

  Future<List<Quiz>> getQuizzes() async {
    dynamic response = await _api.getHTTP(url: '/quizzes');
    List<Quiz> quizzes = [];
    if (response != null) {
      quizzes = List<Quiz>.from(response.map((model) => Quiz.fromJson(model)));
    }
    return quizzes;
  }  

  Future<int> addQuiz(Quiz quiz) async {
    int response = await _api.postHTTP(url: '/quizzes', data: quiz.toJson());
    return response;
  }
}