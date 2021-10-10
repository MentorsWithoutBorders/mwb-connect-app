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
  int quizNumber = 0;

  Future<void> getQuizNumber() async {
    quizNumber = await _quizzesService.getQuizNumber();
  }

  Future<void> addQuiz(Quiz quiz) async {
    _storageService.quizNumber = await _quizzesService.addQuiz(quiz);
    return ;
  }

  void refreshTrainingQuizzesInfo() {   
    if (_storageService.quizNumber != null) {
      quizNumber = _storageService.quizNumber ?? 0;
      _storageService.quizNumber = null;
    }   
    notifyListeners();
  }  

  String getQuizzesLeft() {
    int? weeklyCount = _storageService.quizzesMentorWeeklyCount;
    String quizzesLeft = '';
    if (weeklyCount != null) {
      int quizzesNumber = weeklyCount - ((quizNumber - 1) % weeklyCount);
      String quizzesPlural = plural('quiz', quizzesNumber);
      quizzesLeft = quizzesNumber.toString();
      if (quizzesNumber < weeklyCount) {
        quizzesLeft += ' ' + 'common.more'.tr();
      }
      quizzesLeft += ' ' + quizzesPlural;
    }
    return quizzesLeft;
  }

  bool getShouldShowQuizzes() {
    if (quizNumber != 0) {
      return true;
    } else {
      return false;
    }
  }
  
  bool? get isMentor => _storageService.isMentor;
}
