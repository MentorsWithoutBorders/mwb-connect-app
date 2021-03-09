import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';

class StepsViewModel extends ChangeNotifier {
  Api _api = locator<Api>();

  List<StepModel> steps;
  StepModel selectedStep;
  int previousStepIndex = -1;

  Future<List<StepModel>> fetchSteps({String goalId}) async {
    QuerySnapshot result = await _api.getDataCollection(path: 'goals/' + goalId + '/steps', isForUser: true);
    steps = result.docs
        .map((doc) => StepModel.fromMap(doc.data(), doc.id))
        .toList();
    return steps;
  }

  Stream<QuerySnapshot> fetchStepsAsStream({String goalId}) {
    Stream<QuerySnapshot> result = _api.streamDataCollection(path: 'goals/' + goalId + '/steps', isForUser: true);
    return result;
  }

  Future<StepModel> getStepById({String goalId, String id}) async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'goals/' + goalId + '/steps', isForUser: true, id: id);
    return StepModel.fromMap(doc.data(), doc.id) ;
  }

  Future deleteStep({String goalId, String id}) async {
    await _api.removeDocument(path: 'goals/' + goalId + '/steps', isForUser: true, id: id);
    return ;
  }

  Future updateStep({String goalId, StepModel data, String id}) async {
    await _api.updateDocument(path: 'goals/' + goalId + '/steps', isForUser: true, data: data.toJson(), id: id);
    return ;
  }

  Future<StepModel> addStep({String goalId, StepModel data}) async {
    DocumentReference doc = await _api.addDocument(path: 'goals/' + goalId + '/steps', isForUser: true, data: data.toJson());
    StepModel step = await doc.get().then((datasnapshot) {
      if (datasnapshot.exists) {
        return StepModel(id: doc.id, text: datasnapshot.data()['text']);
      } else {
        return StepModel();
      }
    });
    return step;
  }

  setSelectedStep(StepModel step) {
    selectedStep = step;
    notifyListeners();
  }
  
  List<String> getSubSteps(String stepId) {
    List<String> subSteps = List();
    for (final step in steps){
      if (step.parent == stepId) {
        subSteps.add(step.id);
        if (step.level < 2) {
          List<String> subSubSteps = getSubSteps(step.id);
          subSteps.addAll(subSubSteps);
        }
      }
    }
    return subSteps;
  }

  List<StepModel> sortSteps(List<StepModel> steps) {
    List<StepModel> stepsLevel0 = List();
    List<StepModel> stepsLevel1 = List();
    List<StepModel> stepsLevel2 = List();
    steps.forEach((step) { 
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
    
    List<StepModel> sortedSteps = List();
    // Sort steps level 0
    List<StepModel> sortedStepsLevel0 = _sortStepsByIndex(stepsLevel0);
    sortedStepsLevel0.forEach((sortedStepLevel0) {
      // Add each step level 0 to sorted list
      sortedSteps.add(sortedStepLevel0);
      // Get steps level 1
      List<StepModel> sortedStepsLevel1 = List();
      stepsLevel1.forEach((stepLevel1) {
        if (stepLevel1.parent == sortedStepLevel0.id) {
          sortedStepsLevel1.add(stepLevel1);
        }
      });
      // Sort steps level 1
      sortedStepsLevel1 = _sortStepsByIndex(sortedStepsLevel1);

      sortedStepsLevel1.forEach((sortedStepLevel1) {
        // Add each step level 1 to sorted list
        sortedSteps.add(sortedStepLevel1);
        // Get steps level 2
        List<StepModel> sortedStepsLevel2 = List();
        stepsLevel2.forEach((stepLevel2) {
          if (stepLevel2.parent == sortedStepLevel1.id) {
            sortedStepsLevel2.add(stepLevel2);
          }
        });
        // Sort steps level 2 and add to sorted list
        sortedStepsLevel2 = _sortStepsByIndex(sortedStepsLevel2);
        sortedSteps.addAll(sortedStepsLevel2);    
      });      
    });
    return sortedSteps;
  } 

  List<StepModel> _sortStepsByIndex(List<StepModel> steps) {
    steps.sort((a, b) => a.index.compareTo(b.index));
    return steps;
  }
  
  int getCurrentIndex({List<StepModel> steps, String parentId}) {
    int index = -1;
    steps.forEach((step) {
      if (parentId == null) {
        if (step.level == 0) {
          index = max(index, step.index);
        }
      } else {
        if (step.parent == parentId) {
          index = max(index, step.index);
        }
      }
    });
    return index;
  }

  setAddedStepIndex(List<StepModel> steps, StepModel step) {
    int index = 0;
    List<StepModel> sortedSteps = List();
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
  
  updateIndexesAfterDeleteStep(String goalId, List<StepModel> steps, StepModel step) {
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].parent == step.parent && 
          steps[i].index > step.index) {
        StepModel modifiedStep = steps[i];
        modifiedStep.index--;
        updateStep(goalId: goalId, data: modifiedStep, id: modifiedStep.id);
      }
    }    
  }

  moveStepUp(String goalId, List<StepModel> steps, StepModel step) {
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].parent == step.parent &&
          steps[i].index == step.index - 1) {
        StepModel previousStep = steps[i];
        previousStep.index++;
        step.index--;
        updateStep(goalId: goalId, data: previousStep, id: previousStep.id);
        updateStep(goalId: goalId, data: step, id: step.id);
        break;
      }
    }
  } 

  moveStepDown(String goalId, List<StepModel> steps, StepModel step) {
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].parent == step.parent &&
          steps[i].index == step.index + 1) {
        StepModel nextStep = steps[i];
        nextStep.index--;
        step.index++;
        updateStep(goalId: goalId, data: nextStep, id: nextStep.id);
        updateStep(goalId: goalId, data: step, id: step.id);
        break;
      }
    }
  }
}