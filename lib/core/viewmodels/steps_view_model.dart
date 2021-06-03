import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/services/steps_service.dart';

class StepsViewModel extends ChangeNotifier {
  final StepsService _stepsService = locator<StepsService>();  
  List<StepModel> steps;
  StepModel selectedStep;
  int previousStepIndex = -1;
  bool isTutorialPreviewsAnimationCompleted = false;
  bool shouldShowTutorialChevrons = false;  
  
  Future<List<StepModel>> getSteps(String goalId) async {
    return await _stepsService.getSteps(goalId);
  }

  Future<StepModel> getStepById(String goalId, String id) async {
    return await _stepsService.getStepById(goalId, id);
  }

  Future<void> deleteStep(String id) async {
    await _stepsService.deleteStep(id);
    _deleteStepFromList(id);
    return ;
  }

  Future<void> updateStep(String goalId, StepModel step, String id) async {
    await _stepsService.updateStep(step, id);
    return ;
  }

  Future<StepModel> addStep(String goalId, StepModel step) async { 
    StepModel stepAdded = await _stepsService.addStep(goalId, step);
    _addStepToList(stepAdded);
    return stepAdded;
  }

  void _addStepToList(StepModel step) {
    steps.add(step);
    notifyListeners();
  }
  
  void _deleteStepFromList(String stepId) {
    steps.removeWhere((StepModel step) => step.id == stepId);
    notifyListeners();
  }    

  void setSelectedStep(StepModel step) {
    selectedStep = step;
    notifyListeners();
  }
  
  List<String> getSubSteps(String stepId) {
    final List<String> subSteps = [];
    for (final StepModel step in steps){
      if (step.parentId == stepId) {
        subSteps.add(step.id);
        if (step.level < 2) {
          final List<String> subSubSteps = getSubSteps(step.id);
          subSteps.addAll(subSubSteps);
        }
      }
    }
    return subSteps;
  }

  List<StepModel> sortSteps(List<StepModel> steps) {
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
    return sortedSteps;
  } 

  List<StepModel> _sortStepsByIndex(List<StepModel> steps) {
    steps.sort((a, b) => a.index.compareTo(b.index));
    return steps;
  }
  
  int getCurrentIndex({List<StepModel> steps, String parentId}) {
    int index = -1;
    steps.forEach((StepModel step) {
      if (parentId == null) {
        if (step.level == 0) {
          index = max(index, step.index);
        }
      } else {
        if (step.parentId == parentId) {
          index = max(index, step.index);
        }
      }
    });
    return index;
  }

  void setAddedStepIndex(List<StepModel> steps, StepModel step) {
    int index = 0;
    List<StepModel> sortedSteps = [];
    sortedSteps.addAll(steps);
    sortedSteps.add(step);
    sortedSteps = sortSteps(sortedSteps);
    for (int i = 0; i < sortedSteps.length; i++) {
      if (step.id == sortedSteps[i].id) {
        index = i;
        break;
      }
    }
    previousStepIndex = index;
    notifyListeners();
  }
  
  void updateIndexesAfterDeleteStep(String goalId, List<StepModel> steps, StepModel step) {
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].parentId == step.parentId && 
          steps[i].index > step.index) {
        final StepModel modifiedStep = steps[i];
        modifiedStep.index--;
        updateStep(goalId, modifiedStep, modifiedStep.id);
      }
    }    
  }

  void moveStepUp(String goalId, List<StepModel> steps, StepModel step) {
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].parentId == step.parentId &&
          steps[i].index == step.index - 1) {
        final StepModel previousStep = steps[i];
        previousStep.index++;
        step.index--;
        updateStep(goalId, previousStep, previousStep.id);
        updateStep(goalId, step, step.id);
        break;
      }
    }
  } 

  void moveStepDown(String goalId, List<StepModel> steps, StepModel step) {
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].parentId == step.parentId &&
          steps[i].index == step.index + 1) {
        final StepModel nextStep = steps[i];
        nextStep.index--;
        step.index++;
        updateStep(goalId, nextStep, nextStep.id);
        updateStep(goalId, step, step.id);
        break;
      }
    }
  }

  void setIsTutorialPreviewsAnimationCompleted(bool isCompleted) {
    isTutorialPreviewsAnimationCompleted = isCompleted;
    notifyListeners();
  }   

  void setShouldShowTutorialChevrons(bool showChevrons) {
    shouldShowTutorialChevrons = showChevrons;
    notifyListeners();
  }  
}