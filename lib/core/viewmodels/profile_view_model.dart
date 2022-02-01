import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/utils/string_extension.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = locator<UserService>();
  final ProfileService _profileService = locator<ProfileService>();
  final String _defaultLocale = Platform.localeName;
  User? user;
  List<Field>? fields;
  bool _shouldUnfocus = false;
  double scrollOffset = 0;
  String availabilityMergedMessage = '';    

  Future<void> getUserDetails() async {
    user = await _userService.getUserDetails();
    _sortAvailabilities();
  }

  Future<void> getFields() async {
    fields = await _profileService.getFields();
  }

  void setUserDetails(User? user) {
    _userService.setUserDetails(user);
  }

  void setName(String name) {
    user?.name = name;
    setUserDetails(user);
  }
  
  void setField(Field field) {
    if (user?.field?.id != field.id) {
      user?.field = Field(id: field.id, name: field.name, subfields: []);
      setUserDetails(user);
      notifyListeners();
    }
  }

  Field getSelectedField() {
    return fields!.firstWhere((field) => field.id == user?.field?.id);
  }

  void setSubfield(Subfield subfield, int index) {
    subfield.skills = [];
    List<Subfield>? userSubfields = user?.field?.subfields;
    if (userSubfields != null && index < userSubfields.length) {
      user?.field?.subfields?[index] = subfield;
    } else {
      user?.field?.subfields?.add(subfield);
    }
    setUserDetails(user);
    notifyListeners();
  }

  void addSubfield() {
    final List<Subfield>? subfields = fields?[UtilsFields.getSelectedFieldIndex(user?.field, fields)].subfields;
    final List<Subfield>? userSubfields = user?.field?.subfields;
    if (subfields != null && userSubfields != null) {
      for (final Subfield subfield in subfields) {
        if (!UtilsFields.containsSubfield(userSubfields, subfield)) {
          setSubfield(Subfield(id: subfield.id, name: subfield.name), userSubfields.length+1);
          break;
        }
      }
    }
    notifyListeners();
  }
  
  void deleteSubfield(int index) async {
    List<Subfield> updatedSubfields = [];
    if (user?.field?.subfields != null) {
      for (int i = 0; i < (user?.field?.subfields!.length as int); i++) {
        if (i != index) {
          updatedSubfields.add(user?.field?.subfields![i] as Subfield);
        }
      }
    }
    user?.field?.subfields = [];
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    user?.field?.subfields = updatedSubfields;
    setUserDetails(user);
    notifyListeners();
  }

  void setScrollOffset(double positionDy, double screenHeight, double statusBarHeight) {
    final double height = screenHeight - statusBarHeight - 340;
    if (positionDy > height) {
      scrollOffset = 100;
    } else if (positionDy < height - 50) {
      scrollOffset = positionDy - height;
    }
  }  

  bool addSkill(String skill, int index) {
    Skill? skillToAdd = UtilsFields.setSkillToAdd(skill, index, user?.field, fields);
    if (skillToAdd != null) {
      user?.field?.subfields?[index].skills?.add(skillToAdd);
      setUserDetails(user);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void deleteSkill(String skillId, int index) {
    Skill? skill = user?.field?.subfields?[index].skills?.firstWhere((skill) => skill.id == skillId);
    user?.field?.subfields?[index].skills?.remove(skill);
    setUserDetails(user);
    notifyListeners();
  }

  String getAvailabilityStartDate() {
    final DateFormat dateFormat = DateFormat(AppConstants.dateFormat, _defaultLocale);
    String date = dateFormat.format(DateTime.now()).capitalize();
    if (user?.availableFrom != null) {
      date = dateFormat.format(user?.availableFrom as DateTime).capitalize();
    }
    return date;
  }
  
  void resetAvailabilityMergedMessage() {
    availabilityMergedMessage = '';
    notifyListeners();
  }

  void setIsAvailable(bool isAvailable) {
    user?.isAvailable = isAvailable;
    setUserDetails(user);
    notifyListeners();    
  }

  void setAvailableFrom(DateTime availableFrom) {
    user?.availableFrom = availableFrom;
    setUserDetails(user);
    notifyListeners();
  }
  
  void addAvailability(Availability availability) {
    user?.availabilities?.add(availability);
    _sortAvailabilities();
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(user?.availabilities, availabilityMergedMessage);
    user?.availabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    setUserDetails(user);
    notifyListeners();
  }

  void updateAvailability(int index, Availability newAvailability) {
    user?.availabilities?[index] = newAvailability;
    _sortAvailabilities();
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(user?.availabilities, availabilityMergedMessage);
    user?.availabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    setUserDetails(user);
    notifyListeners();
  }

  void _sortAvailabilities() {
    user?.availabilities?.sort((a, b) => Utils.convertTime12to24(a.time?.from as String)[0].compareTo(Utils.convertTime12to24(b.time?.from as String)[0]));
    user?.availabilities?.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek as String).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek as String)));
    notifyListeners();
  }

  void deleteAvailability(int index) {
    user?.availabilities?.removeAt(index);
    setUserDetails(user);
    notifyListeners();
  }

  void updateLessonsAvailability(LessonsAvailability lessonsAvailability) {
    user?.lessonsAvailability = lessonsAvailability;
    setUserDetails(user);
    notifyListeners();
  }
    
  String? getPeriodUnitPlural(String unit, int number) {
    String? unitPlural;
    if (Utils.periodUnits.contains(unit)) {
      unitPlural = plural(unit, number);
    } else {
      if (Utils.getPeriodUnitsPlural().contains(unit)) {
        unitPlural = plural(Utils.periodUnits[Utils.getPeriodUnitsPlural().indexOf(unit)], number);
      }
    }
    return unitPlural;    
  }

  String? getPeriodUnitSingular(String unit, int number) {
    String? unitSingular;
    if (Utils.periodUnits.contains(unit)) {
      unitSingular = unit;
    } else {
      for (final String periodUnit in Utils.periodUnits) {
        if (plural(periodUnit, number) == unit) {
          unitSingular = periodUnit;
          break;
        }
      }
    }
    return unitSingular;    
  }  

  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }
}
