import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class GoalsService {
  final ApiService _api = locator<ApiService>();

  Future<List<Goal>> getGoals() async {
    dynamic response = await _api.getHTTP(url: '/goals');
    List<Goal> goals = List<Goal>.from(response.map((model) => Goal.fromJson(model)));      
    return goals;
  }

  Future<Goal> getGoalById(String id) async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/goals/$id');
    Goal goal = Goal.fromJson(response);
    return goal;
  }

  Future<Goal> addGoal(Goal goal) async {
    Map<String, dynamic> response = await _api.postHTTP(url: '/goals', data: goal.toJson());  
    Goal addedGoal = Goal.fromJson(response);
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