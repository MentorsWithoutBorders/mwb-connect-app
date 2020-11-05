import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class GoalsViewModel extends ChangeNotifier {
  Api _api = locator<Api>();

  List<Goal> goals;
  Goal selectedGoal;
  bool wasGoalAdded = false;
  bool isTutorialPreviewsAnimationCompleted = false;
  bool shouldShowTutorialChevrons = false;

  Future<List<Goal>> fetchGoals() async {
    QuerySnapshot result = await _api.getDataCollection(path: 'goals', isForUser: true);
    goals = result.documents
        .map((doc) => Goal.fromMap(doc.data, doc.documentID))
        .toList();
    sortGoalList();
    return goals;
  }

  Stream<QuerySnapshot> fetchGoalsAsStream() {
    return _api.streamDataCollection(path: 'goals', isForUser: true);
  }

  Future<Goal> getGoalById(String id) async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'goals', isForUser: true, id: id);
    return Goal.fromMap(doc.data, doc.documentID);
  }

  Future deleteGoal(String id) async {
    _removeGoalFromList(id);
    await _api.removeSubCollection(path: 'goals/' + id + '/steps', isForUser: true);    
    await _api.removeDocument(path: 'goals', isForUser: true, id: id);
    return ;
  }

  Future updateGoal(Goal data, String id) async {
    await _api.updateDocument(path: 'goals', isForUser: true, data: data.toJson(), id: id);
    return ;
  }

  Future<Goal> addGoal(Goal data) async {
    DocumentReference doc = await _api.addDocument(path: 'goals', isForUser: true, data: data.toJson());
    Goal addedGoal = await doc.get().then((datasnapshot) {
      if (datasnapshot.exists) {
        Goal goal = Goal(id: doc.documentID, text: datasnapshot.data['text'], index: datasnapshot.data['index']);
        return goal;
      } else {
        return Goal();
      }
    });    
    return addedGoal;
  }

  _removeGoalFromList(String goalId) {
    goals.removeWhere((goal) => goal.id == goalId);
    notifyListeners();
  }  

  setSelectedGoal(Goal goal) {
    selectedGoal = goal;
    notifyListeners();
  }

  int getCurrentIndex(List<Goal> goals) {
    int index = -1;
    goals.forEach((goal) {
      index = max(index, goal.index);
    });
    return index;
  }  

  addGoalToList(Goal goal) {
    goals.add(goal);
    notifyListeners();
  }
  
  sortGoalList() {
    goals.sort((a, b) => a.index.compareTo(b.index));
    notifyListeners();
  }

  setWasGoalAdded(wasAdded) {
    wasGoalAdded = wasAdded;
  }

  updateIndexesAfterDeleteGoal(String goalId, List<Goal> goals, int index) {
    for (int i = 0; i < goals.length; i++) {
      if (goals[i].index > index) {
        Goal modifiedGoal = goals[i];
        modifiedGoal.index--;
        updateGoal(modifiedGoal, modifiedGoal.id);
      }
    }    
  }

  setIsTutorialPreviewsAnimationCompleted(bool isCompleted) {
    isTutorialPreviewsAnimationCompleted = isCompleted;
    notifyListeners();
  }   

  setShouldShowTutorialChevrons(bool showChevrons) {
    shouldShowTutorialChevrons = showChevrons;
    notifyListeners();
  }

}
