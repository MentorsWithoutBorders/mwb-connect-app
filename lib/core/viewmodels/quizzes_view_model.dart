import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/quiz_status_model.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class QuizzesViewModel extends ChangeNotifier {
  Api _api = locator<Api>();
  LocalStorageService _storageService = locator<LocalStorageService>();

  QuizStatus quizStatus;

  Future<QuizStatus> getQuizStatus() async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'quizzes', isForUser: true, id: 'status');
    QuizStatus data = QuizStatus(solved: '', roundsSolved: 0);
    if (!doc.exists) {
      await _api.setDocument(path: 'quizzes', isForUser: true, data: data.toJson(), id: 'status');
    }
    return doc.exists ? QuizStatus.fromMap(doc.data(), doc.id) : data;
  }

  Future updateQuizStatus(QuizStatus data) async {
    await _api.updateDocument(path: 'quizzes', isForUser: true, data: data.toJson(), id: 'status');
    return ;
  }

  void addQuiz({Quiz data}) async {
    _api.addDocument(path: 'quizzes/status/submitted', isForUser: true, data: data.toJson());
  }  

  getQuizNumber() async {
    quizStatus = await getQuizStatus();
    // Create solved list
    List<int> solvedList = List();
    if (quizStatus.solved != null && quizStatus.solved != '') {
      solvedList = quizStatus.solved.split(', ').map(int.parse).toList();
    }

    // Start a new round
    if (quizStatus.roundsSolved != null &&
          quizStatus.roundsSolved < _storageService.quizzesRounds &&
          solvedList.length == _storageService.quizzesCount &&
          _dateDifference(quizStatus.lastSolved) > _storageService.timeBetweenQuizzesRounds) {
      solvedList = [];
      quizStatus.solved = '';
    }    

    // Get quiz number
    if (solvedList.length < _storageService.quizzesCount) {
      int quizNumber = 1;
      if (_storageService.quizNumber != null && _storageService.quizNumber != -1) {
        quizNumber = _storageService.quizNumber;
      }
      // Get next unsolved quiz
      if (quizStatus.solved != '') {
        bool found = true;
        for (int i = quizNumber; i <= _storageService.quizzesCount; i++) {
          if (!solvedList.contains(i)) {
            quizNumber = i;
            found = false;
            break;
          }
        }
        if (found) {
          for (int i = 1; i <= _storageService.quizzesCount; i++) {
            if (!solvedList.contains(i)) {
              quizNumber = i;
              break;
            }
          }
        }
      }
      _storageService.quizNumber = quizNumber;
    } else {
      _storageService.quizNumber = -1;
    }
  }

  int _dateDifference(DateTime date) {
    final dateNow = DateTime.now();
    return date != null ? dateNow.difference(date).inDays : 0;
  }

  setQuizNumber() {
    if (_storageService.quizNumber == _storageService.quizzesCount) {
      _storageService.quizNumber = 1;
    } else {
      _storageService.quizNumber++;
    }    
  }
  
  setQuizStatus(QuizStatus quizStatus, int solvedNumber) {
    List<int> solvedList = List();
    if (quizStatus.solved != null && quizStatus.solved != '') {
      solvedList = quizStatus.solved.split(', ').map(int.parse).toList();
    }
    if (!solvedList.contains(solvedNumber)) {
      solvedList.add(solvedNumber);
      solvedList.sort();
      quizStatus.solved = solvedList.toString();
      quizStatus.solved = quizStatus.solved.substring(1, quizStatus.solved.length - 1);
      if (solvedList.length == _storageService.quizzesCount) {
        DateTime now = DateTime.now();
        quizStatus.lastSolved = DateTime(now.year, now.month, now.day, now.hour, now.minute);
        quizStatus.roundsSolved++;
      }
      updateQuizStatus(quizStatus);
    }
  }

}
