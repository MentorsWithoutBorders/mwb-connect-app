import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
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

  List<Subfield> getSubfields(int index) {
    final List<Subfield>? subfields = fields?[_getSelectedFieldIndex()].subfields;
    final List<Subfield>? userSubfields = user?.field?.subfields;
    final List<Subfield> filteredSubfields = [];
    if (subfields != null) {
      for (final Subfield subfield in subfields) {
        if (userSubfields != null && !_containsSubfield(userSubfields, subfield) || 
            subfield.name == userSubfields?[index].name) {
          filteredSubfields.add(subfield);
        }
      }
    }
    return filteredSubfields;
  }

  int _getSelectedFieldIndex() {
    final List<Field>? fields = this.fields;
    final Field? selectedField = user?.field;
    return fields!.indexWhere((Field field) => field.id == selectedField?.id);
  }

  bool _containsSubfield(List<Subfield> subfields, Subfield subfield) {
    bool contains = false;
    for (int i = 0; i < subfields.length; i++) {
      if (subfield.name == subfields[i].name) {
        contains = true;
        break;
      }
    }
    return contains;
  }
  
  Subfield? getSelectedSubfield(int index) {
    Subfield? selectedSubfield;
    final List<Subfield>? subfields = fields?[_getSelectedFieldIndex()].subfields;
    final List<Subfield>? userSubfields = user?.field?.subfields;
    if (subfields != null) {
      for (final Subfield subfield in subfields) {
        if (subfield.name == userSubfields?[index].name) {
          selectedSubfield = subfield;
          break;
        }
      }
    }
    return selectedSubfield;
  }

  void addSubfield() {
    final List<Subfield>? subfields = fields?[_getSelectedFieldIndex()].subfields;
    final List<Subfield>? userSubfields = user?.field?.subfields;
    if (subfields != null && userSubfields != null) {
      for (final Subfield subfield in subfields) {
        if (!_containsSubfield(userSubfields, subfield)) {
          setSubfield(Subfield(id: subfield.id, name: subfield.name), userSubfields.length+1);
          break;
        }
      }
    }
    notifyListeners();
  }
  
  void deleteSubfield(int index) {
    user?.field?.subfields?.removeAt(index);
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

  String getSkillHintText(int index) {
    Subfield? subfield = getSelectedSubfield(index);
    String hint = '';
    List<Skill>? subfieldSkills = subfield?.skills;
    if (subfieldSkills != null && subfieldSkills.length > 0) {
      hint = '(' + 'common.eg'.tr() +' ';
      int hintsNumber = 3;
      List<Skill>? subfieldSkills = subfield?.skills;
      if (subfieldSkills != null && subfieldSkills.length < 3) {
        hintsNumber = subfieldSkills.length;
      }
      for (int i = 0; i < hintsNumber; i++) {
        if (subfieldSkills?[i].name != null) {
          String skill = subfieldSkills?[i].name as String;
          hint += skill + ', ';
        }
      }
      hint += 'common.etc'.tr() + ')';
    }
    hint = 'profile.add_skills'.tr(args: [hint]);
    return hint;
  }

  List<String> getSkillSuggestions(String query, int index) {
    List<String> matches = [];
    Subfield? subfield = getSelectedSubfield(index);
    List<Skill>? subfieldSkills = subfield?.skills;
    List<Skill>? userSkills = user?.field?.subfields?[index].skills;
    if (userSkills != null && subfieldSkills != null) {
      for (final Skill skill in subfieldSkills) {
        bool shouldAdd = true;
        for (final Skill userSkill in userSkills) {
          if (skill.id == userSkill.id) {
            shouldAdd = false;
            break;
          }
        }
        if (shouldAdd) {
          matches.add(skill.name as String);
        }
      }
      matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    }
    return matches;
  }

  bool addSkill(String skill, int index) {
    Skill? skillToAdd = _setSkillToAdd(skill, index);
    if (skillToAdd != null) {
      user?.field?.subfields?[index].skills?.add(skillToAdd);
      setUserDetails(user);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Skill? _setSkillToAdd(String skill, int index) {
    Skill? skillToAdd;
    List<Skill>? skills = user?.field?.subfields?[index].skills;
    if (skills != null) {
      for (int i = 0; i < skills.length; i++) {
        if (skill.toLowerCase() == skills[i].name?.toLowerCase()) {
          return null;
        }
      }
    }
    Subfield? subfield = getSelectedSubfield(index);
    List<Skill>? subfieldSkills = subfield?.skills;
    if (subfieldSkills != null) {
      for (int i = 0; i < subfieldSkills.length; i++) {
        if (skill.toLowerCase() == subfieldSkills[i].name?.toLowerCase()) {
          skillToAdd = subfieldSkills[i];
          break;
        }
      }
    }
    return skillToAdd;
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
