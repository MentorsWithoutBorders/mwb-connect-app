import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/available_mentors_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';

class AvailableMentorsViewModel extends ChangeNotifier {
  final AvailableMentorsService _availableMentorsService = locator<AvailableMentorsService>();
  String? availabilityOptionId;
  String? subfieldOptionId; 

  List<User> availableMentors = [];

  Future<List<User>> getAvailableMentors() async {
    availableMentors = await _availableMentorsService.getAvailableMentors();
    return availableMentors;
  }

  void setAvailabilityOptionId(String? id) {
    availabilityOptionId = id;
    if (id != null) {
      String mentorId = id.substring(0, id.indexOf('-a-'));
      if (subfieldOptionId != null && !subfieldOptionId!.contains(mentorId)) {
        subfieldOptionId = null;
      }
    }
    notifyListeners();
  }

  void setSubfieldOptionId(String? id) {
    subfieldOptionId = id;
    if (id != null) {
      String mentorId = id.substring(0, id.indexOf('-s-'));
      if (availabilityOptionId != null && !availabilityOptionId!.contains(mentorId)) {
        availabilityOptionId = null;
      }
    }    
    notifyListeners();
  }  
}
