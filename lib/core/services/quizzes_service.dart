import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';

class QuizzesService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();  

  Future<int> getQuizNumber() async {
    String userId = _storageService.userId;
    http.Response response = await _api.getHTTP(url: '/users/$userId/quiz_number');
    return int.parse(response.body);
  }

  Future<void> addQuiz(Quiz quiz) async {
    String userId = _storageService.userId;
    await _api.postHTTP(url: '/users/$userId/quizzes', data: quiz.toJson());  
  }
}