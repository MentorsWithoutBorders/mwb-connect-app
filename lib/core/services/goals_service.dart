import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class GoalsService {
  final ApiService _api = locator<ApiService>();

  Future<List<Goal>> getGoals() async {
    http.Response response = await _api.getHTTP(url: '/goals');
    var json = jsonDecode(response.body);
    List<Goal> goals = List<Goal>.from(json.map((model) => Goal.fromJson(model)));      
    return goals;
  }

  Future<Goal> getGoalById(String id) async {
    http.Response response = await _api.getHTTP(url: '/goals/$id');
    var json = jsonDecode(response.body);
    Goal goal = Goal.fromJson(json);
    return goal;
  }

  Future<Goal> addGoal(Goal goal) async {
    http.Response response = await _api.postHTTP(url: '/goals', data: goal.toJson());  
    var json = jsonDecode(response.body);
    Goal addedGoal = Goal.fromJson(json);
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