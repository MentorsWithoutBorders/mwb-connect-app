import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/services/steps_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';

class StepsViewModel extends ChangeNotifier {
  final StepsService _stepsService = locator<StepsService>();  
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final LoggerService _loggerService = locator<LoggerService>();  
  List<StepModel> steps = [];
  StepModel? selectedStep;
  StepModel lastStepAdded = StepModel();
  int previousStepPosition = -1;
  bool isTutorialPreviewsAnimationCompleted = false;
  bool shouldShowTutorialChevrons = false;
  
  Future<void> getSteps(String goalId) async {
    steps = await _stepsService.getSteps(goalId);
    _sortSteps();
    return ;
  }

  Future<void> getRemoteSteps(bool shouldGetRemote) async {
    if (shouldGetRemote) {
      await _stepsService.getRemoteSteps();
    }
    return ;
  }  

  Future<StepModel> getStepById(String goalId, String id) async {
    return await _stepsService.getStepById(goalId, id);
  }

  Future<void> getLastStepAdded() async {
    lastStepAdded = await _stepsService.getLastStepAdded();
  }

  Future<void> sendSteps() async {
    Map<String, List<StepModel>> stepsMap = await getStepsMap();
    stepsMap.forEach((goalId, steps) async {
      _stepsService.sendSteps(goalId, steps);
    });
  }

  Future<Map<String, List<StepModel>>> getStepsMap() async {
    List<StepModel> allSteps = await _stepsService.getAllSteps();
    Map<String, List<StepModel>> stepsMap = Map();
    for (StepModel step in allSteps) {
      if (step.goalId != null) {
        String goalId = step.goalId as String;
        if (stepsMap.containsKey(goalId)) {
          stepsMap.update(goalId, (steps) {
            steps.add(step);
            return steps;
          });
        } else {
          stepsMap[goalId] = [step];
        }
      }
    }
    return stepsMap;
  }
  
  Future<void> deleteSteps() async {
    Map<String, List<StepModel>> stepsMap = await getStepsMap();
    stepsMap.forEach((goalId, steps) async {
      await _stepsService.deleteSteps(goalId, steps);
    });
  }   
  
  bool getShouldShowAddStep() {
    DateTime nextDeadline = Utils.getNextDeadline() as DateTime;
    DateTime now = Utils.resetTime(DateTime.now());
    DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
    int limit = Utils.getDSTAdjustedDifferenceInDays(now, registeredOn) > 7 ? 7 : 8;
    if (lastStepAdded.id != null && Utils.getDSTAdjustedDifferenceInDays(nextDeadline, Utils.resetTime(lastStepAdded.dateTime as DateTime)) < limit) {
      return false;
    } else {
      return true;
    }
  }  

  Future<void> addStep({String? goalId, String? stepText, bool? isSubStep}) async {
    int level = 0;
    String? parentId;
    if (isSubStep == true && selectedStep?.level != null) {
      int selectedStepLevel = selectedStep?.level as int;
      level = selectedStepLevel + 1;
      parentId = selectedStep?.id;
    }
    final int position = getCurrentPosition(steps: steps, parentId: parentId) + 1; 
    final StepModel step = StepModel(text: stepText, level: level, position: position, parentId: parentId);
    addLogEntry('add step:\n$stepText');
    StepModel stepAdded = await _stepsService.addStep(goalId, step);
    lastStepAdded.id = stepAdded.id;
    lastStepAdded.dateTime = DateTime.now();
    _addStepToList(stepAdded);
    _setAddedStepPosition(stepAdded);
    sendSteps();
  }
  
  void _addStepToList(StepModel step) {
    steps.add(step);
    _sortSteps();
    notifyListeners();
  }

  void _setAddedStepPosition(StepModel step) {
    int stepsLength = steps.length;
    for (int i = 0; i < stepsLength; i++) {
      if (step.id == steps[i].id) {
        previousStepPosition = i;
        break;
      }
    }
    notifyListeners();
  }  
    
  Future<void> updateStep(StepModel step, String? id, bool shouldSendSteps) async {
    await _stepsService.updateStep(step, id);
    notifyListeners();
    if (shouldSendSteps) {
      sendSteps();
    }
    return ;
  }

  Future<void> deleteStep(String id) async {
    await deleteSteps();
    final List<String> subSteps = getSubSteps(id);
    deleteStepFromList(id);
    if (subSteps.isNotEmpty) {
      subSteps.forEach((String subStepId) async { 
        deleteStepFromList(subStepId);
        await _stepsService.deleteStep(subStepId);
      });
    }
    await _stepsService.deleteStep(id);
    _updatePositionsAfterDeleteStep(selectedStep);
    notifyListeners();
    sendSteps();
    return ;
  }

  void deleteStepFromList(String stepId) {
    steps.removeWhere((StepModel step) => step.id == stepId);
  }    

  void setSelectedStep(StepModel? step) {
    selectedStep = step;
    notifyListeners();
  }
  
  List<String> getSubSteps(String? stepId) {
    final List<String> subSteps = [];
    for (final StepModel step in steps){
      if (step.parentId == stepId) {
        subSteps.add(step.id as String);
        int stepLevel = step.level as int;
        if (stepLevel < 2) {
          final List<String> subSubSteps = getSubSteps(step.id);
          subSteps.addAll(subSubSteps);
        }
      }
    }
    return subSteps;
  }

  void _sortSteps() {
    final List<StepModel> stepsLevel0 = [];
    final List<StepModel> stepsLevel1 = [];
    final List<StepModel> stepsLevel2 = [];
    steps.forEach((StepModel step) { 
      switch(step.level) { 
        case 0: { 
          stepsLevel0.add(step);
        } 
        break; 
        case 1: { 
          stepsLevel1.add(step);
        } 
        break;
        case 2: { 
          stepsLevel2.add(step);
        } 
        break;          
      }
    });
    
    final List<StepModel> sortedSteps = [];
    // Sort steps level 0
    final List<StepModel> sortedStepsLevel0 = _sortStepsByPosition(stepsLevel0);
    sortedStepsLevel0.forEach((StepModel sortedStepLevel0) {
      // Add each step level 0 to sorted list
      sortedSteps.add(sortedStepLevel0);
      // Get steps level 1
      List<StepModel> sortedStepsLevel1 = [];
      stepsLevel1.forEach((StepModel stepLevel1) {
        if (stepLevel1.parentId == sortedStepLevel0.id) {
          sortedStepsLevel1.add(stepLevel1);
        }
      });
      // Sort steps level 1
      sortedStepsLevel1 = _sortStepsByPosition(sortedStepsLevel1);

      sortedStepsLevel1.forEach((StepModel sortedStepLevel1) {
        // Add each step level 1 to sorted list
        sortedSteps.add(sortedStepLevel1);
        // Get steps level 2
        List<StepModel> sortedStepsLevel2 = [];
        stepsLevel2.forEach((StepModel stepLevel2) {
          if (stepLevel2.parentId == sortedStepLevel1.id) {
            sortedStepsLevel2.add(stepLevel2);
          }
        });
        // Sort steps level 2 and add to sorted list
        sortedStepsLevel2 = _sortStepsByPosition(sortedStepsLevel2);
        sortedSteps.addAll(sortedStepsLevel2);    
      });      
    });
    steps = sortedSteps;
  } 

  List<StepModel> _sortStepsByPosition(List<StepModel> steps) {
    steps.sort((a, b) => a.position!.compareTo(b.position as int));
    return steps;
  }
  
  int getCurrentPosition({List<StepModel>? steps, String? parentId}) {
    int position = -1;
    steps?.forEach((StepModel step) {
      if (parentId == null) {
        if (step.level == 0) {
          position = max(position, step.position as int);
        }
      } else {
        if (step.parentId == parentId) {
          position = max(position, step.position as int);
        }
      }
    });
    return position;
  }
  
  void _updatePositionsAfterDeleteStep(StepModel? step) {
    for (int i = 0; i < steps.length; i++) {
      int stepPosition = step?.position as int;
      if (steps[i].parentId == step?.parentId && 
          steps[i].position as int > stepPosition) {
        final StepModel modifiedStep = steps[i];
        int modifiedStepPosition = modifiedStep.position as int;
        modifiedStep.position = modifiedStepPosition - 1;
        addLogEntry('update positions after delete step:\n${modifiedStep.id} - ${modifiedStep.text}');
        updateStep(modifiedStep, modifiedStep.id, false);
      }
    }    
  }

  void moveStepUp(String goalId, StepModel step) {
    for (int i = 0; i < steps.length; i++) {
      int stepPosition = step.position as int;
      if (steps[i].parentId == step.parentId &&
          steps[i].position == stepPosition - 1) {
        final StepModel previousStep = steps[i];
        int previousStepPosition = previousStep.position as int;
        previousStep.position = previousStepPosition + 1;
        int stepPosition = step.position as int;
        step.position = stepPosition - 1;
        addLogEntry('move step up - previous step:\n${previousStep.id} - ${previousStep.text}');
        updateStep(previousStep, previousStep.id, false);
        addLogEntry('move step up - step:\n${step.id} - ${step.text}');
        updateStep(step, step.id, false);
        break;
      }
    }
    _sortSteps();
    sendSteps();
    notifyListeners();
  } 

  void moveStepDown(String goalId, StepModel step) {
    for (int i = 0; i < steps.length; i++) {
      int stepPosition = step.position as int;
      if (steps[i].parentId == step.parentId &&
          steps[i].position == stepPosition + 1) {
        final StepModel nextStep = steps[i];
        int nextStepPosition = nextStep.position as int;
        nextStep.position = nextStepPosition - 1;
        int stepPosition = step.position as int;
        step.position = stepPosition + 1;
        addLogEntry('move step down - next step:\n${nextStep.id} - ${nextStep.text}');
        updateStep(nextStep, nextStep.id, false);
        addLogEntry('move step down - step:\n${step.id} - ${step.text}');        
        updateStep(step, step.id, false);
        break;
      }
    }
    _sortSteps();
    sendSteps();
    notifyListeners();
  }

  void setIsTutorialPreviewsAnimationCompleted(bool isCompleted) {
    isTutorialPreviewsAnimationCompleted = isCompleted;
    notifyListeners();
  }   

  void setShouldShowTutorialChevrons(bool showChevrons) {
    shouldShowTutorialChevrons = showChevrons;
    notifyListeners();
  }
  
  void addLogEntry(String text) {
    _loggerService.addLogEntry(text);
  }  
}