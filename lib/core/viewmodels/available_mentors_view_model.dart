import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/available_mentors_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';

class AvailableMentorsViewModel extends ChangeNotifier {
  final AvailableMentorsService _availableMentorsService = locator<AvailableMentorsService>();
  String? selectedMentorId;
  String? availabilityOptionId;
  String? subfieldOptionId;
  String errorMessage = '';

  List<User> availableMentors = [];

  Future<List<User>> getAvailableMentors() async {
    availableMentors = await _availableMentorsService.getAvailableMentors();
    return availableMentors;
  }

  void setSelectedMentorId(String? id) {
    selectedMentorId = id;
    notifyListeners();
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
  
  bool isLessonRequestValid(User mentor) {
    bool isSubfieldValid = true;
    bool isAvailabilityValid = true;
    if (subfieldOptionId != null && selectedMentorId != null && !subfieldOptionId!.contains(selectedMentorId as String)) {
      setSubfieldOptionId(null);
    }
    if (subfieldOptionId == null) {
      if (mentor.field!.subfields!.length == 1) {
        String mentorId = mentor.id as String;
        setSubfieldOptionId('$mentorId-s-0');
      } else {
        isSubfieldValid = false;
      }
    }
    if (availabilityOptionId != null && selectedMentorId != null && !availabilityOptionId!.contains(selectedMentorId as String)) {
      setAvailabilityOptionId(null);
    }
    if (availabilityOptionId == null) {
      if (mentor.availabilities?.length == 1) {
        String mentorId = mentor.id as String;
        setAvailabilityOptionId('$mentorId-a-0');
      } else {
        isAvailabilityValid = false;
      }
    }
    notifyListeners();
    if (!isSubfieldValid) {
      errorMessage = 'available_mentors.please_select_error'.tr() + ' '  + 'available_mentors.subfield_error'.tr();
      if (!isAvailabilityValid) {
        errorMessage += ' ' + 'common.and'.tr() + ' '  + 'available_mentors.availability_error'.tr();
      }
      return false;
    } else if (!isAvailabilityValid) {
      errorMessage = 'available_mentors.please_select_error'.tr() + ' '  + 'available_mentors.availability_error'.tr();
      return false;
    }
    return true;
  }

  void setErrorMessage(String message) {
    errorMessage = message;
  }
}
