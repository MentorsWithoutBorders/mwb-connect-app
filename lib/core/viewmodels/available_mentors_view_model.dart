import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/field_goal_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/services/available_mentors_service.dart';
import 'package:mwb_connect_app/core/services/fields_goals_service.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';

class AvailableMentorsViewModel extends ChangeNotifier {
  final AvailableMentorsService _availableMentorsService = locator<AvailableMentorsService>();
  final FieldsGoalsService _fieldsGoalsService = locator<FieldsGoalsService>();
  List<User> availableMentors = [];
  List<FieldGoal> fieldsGoals = [];
  List<Availability> filterAvailabilities = [];
  List<Field> fields = [];
  User? selectedMentor;
  String? availabilityOptionId;
  String? subfieldOptionId;
  String? lessonRequestButtonId;
  String? selectedLessonStartTime;
  Field filterField = Field();
  String availabilityMergedMessage = '';
  double scrollOffset = 0;  
  String errorMessage = '';
  bool _shouldUnfocus = false;

  Future<void> getAvailableMentors() async {
    availableMentors = await _availableMentorsService.getAvailableMentors();
    setSelectedMentor(null);
    setSelectedLessonStartTime(null);
    _sortMentorsAvailabilities();
  }

  Future<void> getFieldsGoals() async {
    fieldsGoals = await _fieldsGoalsService.getFieldsGoals();
  }
  
  Future<void> getFields() async {
    fields = await _availableMentorsService.getFields();
  }  

  Future<void> sendCustomLessonRequest() async {
    await _availableMentorsService.sendCustomLessonRequest(selectedMentor);
  }
  
  String? getWhyChooseUrl(String fieldId) {
    for (FieldGoal fieldGoal in fieldsGoals) {
      if (fieldGoal.fieldId == fieldId) {
        return fieldGoal.whyChooseUrl;
      }
    }
  }

  void _sortMentorsAvailabilities() {
    for (User mentor in availableMentors) {
      mentor.availabilities?.sort((a, b) => Utils.convertTime12to24(a.time?.from as String)[0].compareTo(Utils.convertTime12to24(b.time?.from as String)[0]));
      mentor.availabilities?.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek as String).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek as String)));
    }
    notifyListeners();
  }

  void setSelectedMentor(User? mentor) {
    if (mentor != null) {
      if (selectedMentor == null) {
        selectedMentor = User(id: mentor.id);
        selectedMentor?.field = Field(
          id: mentor.field?.id,
          subfields: [getSelectedSubfield()]
        );
        selectedMentor?.availabilities = [getSelectedAvailability()];
        final String? timeFrom = selectedMentor?.availabilities![0].time?.from;
        if (timeFrom != null) {
          setSelectedLessonStartTime(timeFrom);
        }
      } else {
        final Availability availabilityUtc = UtilsAvailabilities.getAvailabilityToUtc(selectedMentor?.availabilities![0] as Availability);
        final List<int> availabilityTimeFrom = Utils.convertTime12to24(availabilityUtc.time?.from as String);
        final List<int> lessonStartTime = Utils.convertTime12to24(selectedLessonStartTime as String);
        final DateTime date = Utils.resetTime(DateTime.now());
        final DateTime timeFromUtc = date.copyWith(hour: availabilityTimeFrom[0]).toUtc();
        final DateTime lessonStartTimeUtc = date.copyWith(hour: lessonStartTime[0]).toUtc();
        if (lessonStartTimeUtc.isBefore(timeFromUtc)) {
          selectedMentor?.availabilities![0].dayOfWeek = Utils.getNextDayOfWeek(selectedMentor?.availabilities![0].dayOfWeek as String);
        }
        selectedMentor?.availabilities![0].time?.from = selectedLessonStartTime;
      }
    } else {
      selectedMentor = null;
    }
    notifyListeners();
  }

  void setSelectedLessonStartTime(String? startTime) {
    selectedLessonStartTime = startTime;
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

  void setLessonRequestButtonId(String? id) {
    lessonRequestButtonId = id;   
    notifyListeners();
  }  

  void setDefaultSubfield(User mentor) {
    if (subfieldOptionId != null && lessonRequestButtonId != null && !subfieldOptionId!.contains(lessonRequestButtonId as String)) {
      setSubfieldOptionId(null);
    }
    if (subfieldOptionId == null) {
      if (mentor.field!.subfields!.length == 1) {
        String mentorId = mentor.id as String;
        setSubfieldOptionId('$mentorId-s-0');
      }
    }
    notifyListeners();
  }

  void setDefaultAvailability(User mentor) {
    if (availabilityOptionId != null && lessonRequestButtonId != null && !availabilityOptionId!.contains(lessonRequestButtonId as String)) {
      setAvailabilityOptionId(null);
    }
    if (availabilityOptionId == null) {
      if (mentor.availabilities?.length == 1) {
        String mentorId = mentor.id as String;
        setAvailabilityOptionId('$mentorId-a-0');
      }
    }
    notifyListeners();
  }
  
  bool isLessonRequestValid(User mentor) {
    bool isSubfieldValid = true;
    bool isAvailabilityValid = true;
    if (subfieldOptionId == null) {
      isSubfieldValid = false;
    }
    if (availabilityOptionId == null) {
      isAvailabilityValid = false;
    }
    if (!isSubfieldValid) {
      errorMessage = 'available_mentors.please_select_error'.tr() + ' ' + 'available_mentors.subfield_error'.tr();
      if (!isAvailabilityValid) {
        errorMessage += ' ' + 'common.and'.tr() + ' '  + 'available_mentors.availability_error'.tr();
      }
      notifyListeners();
      return false;
    } else if (!isAvailabilityValid) {
      errorMessage = 'available_mentors.please_select_error'.tr() + ' ' + 'available_mentors.availability_error'.tr();
      notifyListeners();
      return false;
    }
    return true;
  }

  void setErrorMessage(String message) {
    errorMessage = message;
  }

  Subfield getSelectedSubfield() {
    if (subfieldOptionId != null) {
      for (final User mentor in availableMentors) {
        if (mentor.id == selectedMentor?.id) {
          int index = int.parse(subfieldOptionId!.substring(subfieldOptionId!.indexOf('-s-') + 3));
          return mentor.field?.subfields![index] as Subfield;
        }
      }
    }
    return Subfield();
  }  

  Availability getSelectedAvailability() {
    if (availabilityOptionId != null) {
      for (final User mentor in availableMentors) {
        if (mentor.id == selectedMentor?.id) {
          int index = int.parse(availabilityOptionId!.substring(availabilityOptionId!.indexOf('-a-') + 3));
          return mentor.availabilities![index];
        }
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
      hoursList = _setHours(hoursList, timeFromHours, timeToHours);
    } else {
      hoursList = _setHours(hoursList, timeFromHours, 24);
      hoursList = _setHours(hoursList, 0, timeToHours);
    }
    return hoursList;
  }
  
  List<String> _setHours(List<String> hoursList, int from, int to) {
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

  void addAvailability(Availability availability) {
    filterAvailabilities.add(availability);
    _sortFilterAvailabilities();
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(filterAvailabilities, availabilityMergedMessage);
    filterAvailabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    notifyListeners();
  }
  
  void _sortFilterAvailabilities() {
    filterAvailabilities.sort((a, b) => Utils.convertTime12to24(a.time?.from as String)[0].compareTo(Utils.convertTime12to24(b.time?.from as String)[0]));
    filterAvailabilities.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek as String).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek as String)));
    notifyListeners();
  }
  
  void updateAvailability(int index, Availability newAvailability) {
    filterAvailabilities[index] = newAvailability;
    _sortFilterAvailabilities();
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(filterAvailabilities, availabilityMergedMessage);
    filterAvailabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    notifyListeners();
  }
  
  void deleteAvailability(int index) {
    filterAvailabilities.removeAt(index);
    notifyListeners();
  }
 
  void setField(Field field) {
    if (filterField.id != field.id) {
      filterField = Field(id: field.id, name: field.name, subfields: []);
      notifyListeners();
    }
  }

  Field getSelectedField() {
    return fields.firstWhere((field) => field.id == filterField.id);
  }

  void setSubfield(Subfield subfield, int index) {
    subfield.skills = [];
    List<Subfield>? filterSubfields = filterField.subfields;
    if (filterSubfields != null && index < filterSubfields.length) {
      filterField.subfields?[index] = subfield;
    } else {
      filterField.subfields?.add(subfield);
    }
    notifyListeners();
  }

  void addSubfield() {
    final List<Subfield>? subfields = fields[UtilsFields.getSelectedFieldIndex(filterField, fields)].subfields;
    final List<Subfield>? filterSubfields = filterField.subfields;
    if (subfields != null && filterSubfields != null) {
      for (final Subfield subfield in subfields) {
        if (!UtilsFields.containsSubfield(filterSubfields, subfield)) {
          setSubfield(Subfield(id: subfield.id, name: subfield.name), filterSubfields.length+1);
          break;
        }
      }
    }
    notifyListeners();
  }
  
  void deleteSubfield(int index) {
    filterField.subfields?.removeAt(index);
    notifyListeners();
  }

  bool addSkill(String skill, int index) {
    Skill? skillToAdd = UtilsFields.setSkillToAdd(skill, index, filterField, fields);
    if (skillToAdd != null) {
      filterField.subfields?[index].skills?.add(skillToAdd);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void deleteSkill(String skillId, int index) {
    Skill? skill = filterField.subfields?[index].skills?.firstWhere((skill) => skill.id == skillId);
    filterField.subfields?[index].skills?.remove(skill);
    notifyListeners();
  }  

  void resetAvailabilityMergedMessage() {
    availabilityMergedMessage = '';
  }  
  
  void setScrollOffset(double positionDy, double screenHeight, double statusBarHeight) {
    final double height = screenHeight - statusBarHeight - 340;
    if (positionDy > height) {
      scrollOffset = 100;
    } else if (positionDy < height - 50) {
      scrollOffset = positionDy - height;
    }
  }    
  
  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }  
}
