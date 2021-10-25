import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';

class StepsService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();  

  Future<List<StepModel>> getSteps(String goalId) async {
    dynamic response = await _api.getHTTP(url: '/goals/$goalId/steps');
    List<StepModel> steps = List<StepModel>.from(response.map((model) => StepModel.fromJson(model)));      
    return steps;
  }

  Future<StepModel> getStepById(String goalId, String id) async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/steps/$id');
    StepModel step = StepModel.fromJson(response);
    return step;
  }

  Future<StepModel> getLastStepAdded() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/last_step_added');
    StepModel step = StepModel.fromJson(response);
    return step;
  }    

  Future<StepModel> addStep(String? goalId, StepModel step) async {
    Map<String, dynamic> response = await _api.postHTTP(url: '/goals/$goalId/steps', data: step.toJson());  
    StepModel addedStep = StepModel.fromJson(response);
    return addedStep;
  }  

  Future<void> updateStep(StepModel step, String? id) async {
    await _api.putHTTP(url: '/steps/$id', data: step.toJson());  
    return ;
  }  

  Future<void> deleteStep(String id) async {
    await _api.deleteHTTP(url: '/steps/$id');
    return ;
  }  
}