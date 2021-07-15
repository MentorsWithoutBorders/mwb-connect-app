import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class GoalsService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();  

  Future<List<Goal>> getGoals() async {
    http.Response response = await _api.getHTTP(url: '/goals');
    List<Goal> goals = [];
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      goals = List<Goal>.from(json.map((model) => Goal.fromJson(model)));      
    }
    return goals;
  }

  Future<Goal> getGoalById(String id) async {
    http.Response response = await _api.getHTTP(url: '/goals/$id');
    Goal goal;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      goal = Goal.fromJson(json);
    }
    return goal;
  }

  Future<Goal> addGoal(Goal goal) async {
    http.Response response = await _api.postHTTP(url: '/goals', data: goal.toJson());  
    Goal addedGoal;
    if (response != null) {
      var json = jsonDecode(response.body);
      addedGoal = Goal.fromJson(json);
    }
    return addedGoal;
  }

  Future<void> updateGoal(Goal goal, String id) async {
    await _api.putHTTP(url: '/goals/$id', data: goal.toJson());  
    return ;
  }     

  Future<void> deleteGoal(String id) async {
    await _api.deleteHTTP(url: '/goals/$id');
    return ;
  } 
}