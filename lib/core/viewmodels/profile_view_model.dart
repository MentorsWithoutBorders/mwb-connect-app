import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/utils/string_extension.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = locator<UserService>();
  final ProfileService _profileService = locator<ProfileService>();
  User? user;
  List<Field>? fields;
  bool _shouldUnfocus = false;
  double scrollOffset = 0;
  String availabilityMergedMessage = '';    

  Future<void> getUserDetails() async {
    user = await _userService.getUserDetails();
    user?.availabilities = _adjustAvailabilitiesTimeFormat(user?.availabilities);
    user?.availabilities = UtilsAvailabilities.getSortedAvailabilities(user?.availabilities);
  }

  List<Availability>? _adjustAvailabilitiesTimeFormat(List<Availability>? availabilities) {
    List<Availability>? adjustedAvailabilities = [];
    if (availabilities != null) {
      for (Availability availability in availabilities) {
        DateFormat timeFormat = DateFormat('ha', 'en');    
        DateTime date = Utils.resetTime(DateTime.now());
        List<int> availabilityTimeFrom = Utils.convertTime12to24(availability.time?.from as String);
        List<int> availabilityTimeTo = Utils.convertTime12to24(availability.time?.to as String);
        DateTime timeFrom = date.copyWith(hour: availabilityTimeFrom[0]);
        DateTime timeTo = date.copyWith(hour: availabilityTimeTo[0]);
        adjustedAvailabilities.add(Availability(
          dayOfWeek: availability.dayOfWeek,
          time: Time(
            from: timeFormat.format(timeFrom).toLowerCase(),
            to: timeFormat.format(timeTo).toLowerCase()
          )
        ));
      }
    }
    return adjustedAvailabilities;
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
    final DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');
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
    user?.availabilities = UtilsAvailabilities.getSortedAvailabilities(user?.availabilities);
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(user?.availabilities, availabilityMergedMessage);
    user?.availabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    setUserDetails(user);
    notifyListeners();
  }

  void updateAvailability(int index, Availability newAvailability) {
    user?.availabilities?[index] = newAvailability;
    user?.availabilities = UtilsAvailabilities.getSortedAvailabilities(user?.availabilities);
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(user?.availabilities, availabilityMergedMessage);
    user?.availabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    setUserDetails(user);
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

  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }
}
