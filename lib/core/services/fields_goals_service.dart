import 'dart:async';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/field_goal_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class FieldsGoalsService {
  final ApiService _api = locator<ApiService>();

  Future<List<FieldGoal>> getFieldsGoals() async {
    dynamic response = await _api.getHTTP(url: '/fields_goals');
    List<FieldGoal> fieldsGoals = [];
    if (response != null) {
      fieldsGoals = List<FieldGoal>.from(response.map((model) => FieldGoal.fromJson(model)));      
    }    
    return fieldsGoals;
  }
}