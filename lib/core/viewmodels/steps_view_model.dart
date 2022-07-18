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
  List<StepModel>? steps;
  StepModel? selectedStep;
  StepModel lastStepAdded = StepModel();
  int previousStepIndex = -1;
  bool isTutorialPreviewsAnimationCompleted = false;
  bool shouldShowTutorialChevrons = false;  
  
  Future<void> getSteps(String goalId) async {
    steps = await _stepsService.getSteps(goalId);
    _sortSteps();
    return ;
  }

  Future<StepModel> getStepById(String goalId, String id) async {
    return await _stepsService.getStepById(goalId, id);
  }

  Future<void> getLastStepAdded() async {
    lastStepAdded = await _stepsService.getLastStepAdded();
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
    final int index = getCurrentIndex(steps: steps, parentId: parentId) + 1; 
    final StepModel step = StepModel(text: stepText, level: level, index: index, parentId: parentId);
    addLogEntry('add step:\n$stepText');
    StepModel stepAdded = await _stepsService.addStep(goalId, step);
    lastStepAdded.id = stepAdded.id;
    lastStepAdded.dateTime = DateTime.now();    
    _addStepToList(stepAdded);
    _setAddedStepIndex(stepAdded);
  }
  
  void _addStepToList(StepModel step) {
    steps?.add(step);
    _sortSteps();
    notifyListeners();
  }

  void _setAddedStepIndex(StepModel step) {
    if (steps != null) {
      int stepsLength = steps?.length as int;
      for (int i = 0; i < stepsLength; i++) {
        if (step.id == steps?[i].id) {
          previousStepIndex = i;
          break;
        }
      }
    }
    notifyListeners();
  }  
    
  Future<void> updateStep(StepModel step, String? id) async {
    await _stepsService.updateStep(step, id);
    notifyListeners();
    return ;
  }

  Future<void> deleteStep(String id) async {
    final List<String> subSteps = getSubSteps(id);
    deleteStepFromList(id);
    if (subSteps.isNotEmpty) {
      subSteps.forEach((String subStepId) async { 
        deleteStepFromList(subStepId);
        await _stepsService.deleteStep(subStepId);
      });
    }
    await _stepsService.deleteStep(id);
    _updateIndexesAfterDeleteStep(selectedStep);
    notifyListeners();
    return ;
  }

  void deleteStepFromList(String stepId) {
    steps?.removeWhere((StepModel step) => step.id == stepId);
  }    

  void setSelectedStep(StepModel? step) {
    selectedStep = step;
    notifyListeners();
  }
  
  List<String> getSubSteps(String? stepId) {
    final List<String> subSteps = [];
    if (steps != null) {
      for (final StepModel step in steps!){
        if (step.parentId == stepId) {
          subSteps.add(step.id as String);
          int stepLevel = step.level as int;
          if (stepLevel < 2) {
            final List<String> subSubSteps = getSubSteps(step.id);
            subSteps.addAll(subSubSteps);
          }
        }
      }
    }
    return subSteps;
  }

  void _sortSteps() {
    final List<StepModel> stepsLevel0 = [];
    final List<StepModel> stepsLevel1 = [];
    final List<StepModel> stepsLevel2 = [];
    steps?.forEach((StepModel step) { 
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
    final List<StepModel> sortedStepsLevel0 = _sortStepsByIndex(stepsLevel0);
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
      sortedStepsLevel1 = _sortStepsByIndex(sortedStepsLevel1);

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
        sortedStepsLevel2 = _sortStepsByIndex(sortedStepsLevel2);
        sortedSteps.addAll(sortedStepsLevel2);    
      });      
    });
    steps = sortedSteps;
  } 

  List<StepModel> _sortStepsByIndex(List<StepModel> steps) {
    steps.sort((a, b) => a.index!.compareTo(b.index as int));
    return steps;
  }
  
  int getCurrentIndex({List<StepModel>? steps, String? parentId}) {
    int index = -1;
    steps?.forEach((StepModel step) {
      if (parentId == null) {
        if (step.level == 0) {
          index = max(index, step.index as int);
        }
      } else {
        if (step.parentId == parentId) {
          index = max(index, step.index as int);
        }
      }
    });
    return index;
  }
  
  void _updateIndexesAfterDeleteStep(StepModel? step) {
    for (int i = 0; i < steps!.length; i++) {
      int stepIndex = step?.index as int;
      if (steps?[i].parentId == step?.parentId && 
          steps?[i].index as int > stepIndex) {
        final StepModel modifiedStep = steps?[i] as StepModel;
        int modifiedStepIndex = modifiedStep.index as int;
        modifiedStep.index = modifiedStepIndex - 1;
        addLogEntry('update indexes after delete step:\n${modifiedStep.id} - ${modifiedStep.text}');
        updateStep(modifiedStep, modifiedStep.id);
      }
    }    
  }

  void moveStepUp(String goalId, StepModel step) {
    for (int i = 0; i < steps!.length; i++) {
      int stepIndex = step.index as int;
      if (steps?[i].parentId == step.parentId &&
          steps?[i].index == stepIndex - 1) {
        final StepModel previousStep = steps?[i] as StepModel;
        int previousStepIndex = previousStep.index as int;
        previousStep.index = previousStepIndex + 1;
        int stepIndex = step.index as int;
        step.index = stepIndex - 1;
        addLogEntry('move step up - previous step:\n${previousStep.id} - ${previousStep.text}');
        updateStep(previousStep, previousStep.id);
        addLogEntry('move step up - step:\n${step.id} - ${step.text}');
        updateStep(step, step.id);
        break;
      }
    }
    _sortSteps();
    notifyListeners();
  } 

  void moveStepDown(String goalId, StepModel step) {
    for (int i = 0; i < steps!.length; i++) {
      int stepIndex = step.index as int;
      if (steps?[i].parentId == step.parentId &&
          steps?[i].index == stepIndex + 1) {
        final StepModel nextStep = steps?[i] as StepModel;
        int nextStepIndex = nextStep.index as int;
        nextStep.index = nextStepIndex - 1;
        int stepIndex = step.index as int;
        step.index = stepIndex + 1;
        addLogEntry('move step down - next step:\n${nextStep.id} - ${nextStep.text}');
        updateStep(nextStep, nextStep.id);
        addLogEntry('move step down - step:\n${step.id} - ${step.text}');        
        updateStep(step, step.id);
        break;
      }
    }
    _sortSteps();
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