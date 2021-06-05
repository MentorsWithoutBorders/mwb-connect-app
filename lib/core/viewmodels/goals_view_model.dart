import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class GoalsViewModel extends ChangeNotifier {
  final GoalsService _goalsService = locator<GoalsService>();   

  List<Goal> goals;
  Goal selectedGoal;
  bool wasGoalAdded = false;

  Future<List<Goal>> getGoals() async {
    goals = await _goalsService.getGoals();
    return goals;
  }

  Future<void> deleteGoal(String id) async {
    _deleteGoalFromList(id);
    await _goalsService.deleteGoal(id);
    return ;
  }

  Future<void> updateGoal(Goal goal, String id) async {
    await _goalsService.updateGoal(goal, id);
    return ;
  }

  Future<void> addGoal(String goalText) async {
    Goal goal = Goal(text: goalText);
    Goal addedGoal = await _goalsService.addGoal(goal);
    addGoalToList(addedGoal);
    setWasGoalAdded(true);    
    return ;
  }

  void _deleteGoalFromList(String goalId) {
    goals.removeWhere((Goal goal) => goal.id == goalId);
    notifyListeners();
  }  

  void setSelectedGoal(Goal goal) {
    selectedGoal = goal;
    notifyListeners();
  }

  void addGoalToList(Goal goal) {
    goals.add(goal);
    notifyListeners();
  }

  void setWasGoalAdded(bool wasAdded) {
    wasGoalAdded = wasAdded;
  }
}
