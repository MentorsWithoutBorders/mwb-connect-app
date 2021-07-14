import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/services/quizzes_service.dart';

class QuizzesViewModel extends ChangeNotifier {
  final QuizzesService _quizzesService = locator<QuizzesService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();  

  Future<int> getQuizNumber() async {
    return await _quizzesService.getQuizNumber();
  }

  Future<void> addQuiz(Quiz quiz) async {
    await _quizzesService.addQuiz(quiz);
    return ;
  }
  
  bool get isMentor => _storageService.isMentor;
}
