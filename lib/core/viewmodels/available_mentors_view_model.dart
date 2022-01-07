import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/available_mentors_service.dart';

class AvailableMentorsViewModel extends ChangeNotifier {
  final AvailableMentorsService _availableMentorsService = locator<AvailableMentorsService>();
  String? selectedMentorId;
  String? availabilityOptionId;
  String? subfieldOptionId;
  String errorMessage = '';

  List<User> availableMentors = [];

  Future<void> getAvailableMentors() async {
    availableMentors = await _availableMentorsService.getAvailableMentors();
    _sortAvailabilities();
  }

  void _sortAvailabilities() {
    for (User mentor in availableMentors) {
      mentor.availabilities?.sort((a, b) => Utils.convertTime12to24(a.time?.from as String)[0].compareTo(Utils.convertTime12to24(b.time?.from as String)[0]));
      mentor.availabilities?.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek as String).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek as String)));
    }
    notifyListeners();
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

  Availability getSelectedAvailability() {
    for (final User mentor in availableMentors) {
      if (mentor.id == selectedMentorId) {
        int index = int.parse(availabilityOptionId!.substring(availabilityOptionId!.indexOf('-a-') + 3));
        return mentor.availabilities![index];
      }
    }
    return Availability();
  }

  List<String> buildHoursList() {
    final Availability availability = getSelectedAvailability();
    String timeFrom = availability.time?.from as String;
    String timeTo = availability.time?.to as String;
    int timeFromHours = Utils.convertTime12to24(timeFrom)[0];
    int timeToHours = Utils.convertTime12to24(timeTo)[0];

    List<String> hoursList = [];
    if (timeFromHours < timeToHours) {
      hoursList = _setHours(timeFromHours, timeToHours);
    } else {
      hoursList = _setHours(timeFromHours, 24);
    }
    return hoursList;
  }
  
  List<String> _setHours(int from, int to) {
    List<String> hoursList = [];
    if (from < 12) {
      if (to < 12) {
        hoursList = _addHours(hoursList, from, to - 1, 'am');
      } else {
        hoursList = _addHours(hoursList, from, 11, 'am');
        if (to > 12) {
          hoursList.add('12pm');
          hoursList = _addHours(hoursList, 1, to - 13, 'pm');
        }
      }
    } else {
      if (from == 12) {
        hoursList.add('12pm');
        hoursList = _addHours(hoursList, from - 11, to - 13, 'pm');
      } else {
        hoursList = _addHours(hoursList, from - 12, to - 13, 'pm');
      }
    }

    return hoursList;
  }

  List<String> _addHours(List<String> hoursList, int from, int to, String modifier) {
    for (int i = from; i <= to; i++) {
      if (i == 0) {
        hoursList.add('12am');
      } else {
        hoursList.add(i.toString() + modifier);
      }
    }
    return hoursList;
  }
}
