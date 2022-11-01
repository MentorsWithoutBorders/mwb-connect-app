import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class GoalsViewModel extends ChangeNotifier {
  final GoalsService _goalsService = locator<GoalsService>();   
  final LoggerService _loggerService = locator<LoggerService>();  

  List<Goal> goals = [];
  Goal? selectedGoal;
  bool wasGoalAdded = false;

  Future<void> getGoals() async {
    goals = await _goalsService.getGoals();
    if (goals.isNotEmpty) {
      setSelectedGoal(goals[0]);
    } else {
      addLogEntry('setting goal to null in getGoal()');
      setSelectedGoal(null);
    }    
  }

  Future<void> getRemoteGoals(bool shouldGetRemote) async {
    if (shouldGetRemote) {
      await _goalsService.getRemoteGoals();  
    }
  }  

  Future<void> deleteGoal(String id) async {
    _deleteGoalFromList(id);
    await _goalsService.deleteGoal(id);
    return ;
  }

  Future<void> updateGoal(Goal goal, String id) async {
    await _goalsService.updateGoal(goal, id);
    notifyListeners();
    return ;
  }

  Future<Goal> addGoal(String goalText) async {
    Goal goal = Goal(text: goalText);
    Goal addedGoal = await _goalsService.addGoal(goal);
    addGoalToList(addedGoal);
    setWasGoalAdded(true);    
    return addedGoal;
  }

  void _deleteGoalFromList(String goalId) {
    goals.removeWhere((Goal goal) => goal.id == goalId);
    notifyListeners();
  }  

  void setSelectedGoal(Goal? goal) {
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

  void sendAPIDataLogs(int i, String error, List<String> logs) {
    String attemptText = 'goal_steps_view attempt ' + i.toString();
    if (error != '') {
      attemptText += ', error: ' + error;
    }
    attemptText += '\n';
    for (String log in logs) {
      attemptText += log + '\n';
    }
    addLogEntry(attemptText);
  }  

  void addLogEntry(String text) {
    _loggerService.addLogEntry(text);
  }  
}
