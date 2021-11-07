import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/services/quizzes_service.dart';

class QuizzesViewModel extends ChangeNotifier {
  final QuizzesService _quizzesService = locator<QuizzesService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  int quizNumber = 1;
  int quizNumberIndex = 1;
  List<Quiz> quizzes = [];
  bool wasClosed = false;

  Future<void> getQuizzes() async {
    quizzes = await _quizzesService.getQuizzes();
    calculateQuizNumber();
  }
  
  void calculateQuizNumber() {
    quizNumber = 0;
    for (int i = 0; i < quizzes.length; i++) {
      if (quizzes[i].isCorrect != true) {
        quizNumber = quizzes[i].number as int;
        break;
      }
    }
  }

  void calculateQuizNumberIndex() {
    quizNumberIndex = 1;
    for (int i = 0; i < quizzes.length; i++) {
      if (quizzes[i].isCorrect != true) {
        quizNumberIndex = i + 1;
        break;
      }
    }
  }  

  int addQuiz(Quiz quiz) {
    if (quiz.isCorrect == true) {
      for (int i = 0; i < quizzes.length; i++) {
        if (quizzes[i].number == quiz.number) {
          quizzes[i].isCorrect = true;
          break;
        }
      }
      wasClosed = true;
      calculateQuizNumber();
      notifyListeners();
    }
    _quizzesService.addQuiz(quiz);
    return quizNumber;
  }

  int calculateRemainingQuizzes() {
    int remainingQuizzes = 0;
    for (int i = 0; i < quizzes.length; i++) {
      if (quizzes[i].isCorrect != true) {
        remainingQuizzes++;
      }
    }    
    return remainingQuizzes;
  }

  String getRemainingQuizzesText() {
    int remainingQuizzes = calculateRemainingQuizzes();
    String quizzesPlural = plural('quiz', remainingQuizzes);
    String remainingQuizzesText = remainingQuizzes.toString();
    if (remainingQuizzes < quizzes.length) {
      remainingQuizzesText += ' ' + 'common.more'.tr();
    }
    remainingQuizzesText += ' ' + quizzesPlural;
    return remainingQuizzesText;
  }  

  bool getShouldShowQuizzes() {
    int remainingQuizzes = calculateRemainingQuizzes();
    if (remainingQuizzes > 0) {
      return true;
    } else {
      return false;
    }
  }
  
  bool? get isMentor => _storageService.isMentor;
}
