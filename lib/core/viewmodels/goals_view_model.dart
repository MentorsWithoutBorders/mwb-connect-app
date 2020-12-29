import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class GoalsViewModel extends ChangeNotifier {
  GoalsService _goalsService = locator<GoalsService>();   

  List<Goal> goals;
  Goal selectedGoal;
  bool wasGoalAdded = false;
  bool isTutorialPreviewsAnimationCompleted = false;
  bool shouldShowTutorialChevrons = false;

  Future<List<Goal>> fetchGoals() async {
    goals = await _goalsService.fetchGoals();
    return goals;
  }

  Stream<QuerySnapshot> fetchGoalsAsStream() {
    return _goalsService.fetchGoalsAsStream();
  }

  Future<Goal> getGoalById(String id) async {
    return _goalsService.getGoalById(id);
  }

  Future deleteGoal(String id) async {
    _removeGoalFromList(id);
    await _goalsService.deleteGoal(id);
    return ;
  }

  Future updateGoal(Goal goal, String id) async {
    await _goalsService.updateGoal(goal, id);
    return ;
  }

  Future<Goal> addGoal(Goal goal) async {  
    return _goalsService.addGoal(goal);
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
