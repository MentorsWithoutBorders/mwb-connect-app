import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = locator<UserService>();
  final ProfileService _profileService = locator<ProfileService>();
  Profile profile;
  String availabilityMergedMessage = '';
  bool _mergedAvailabilityLastShown = false;
  bool _shouldUnfocus = false;

  Future<User> getUserDetails() async {
    return _userService.getUserDetails();
  }

  Future<List<Field>> getFields() async {
    return _profileService.getFields();
  }

  void setFields(List<Field> fields) {
    fields.forEach((Field field) {
      _profileService.addField(field);
    });    
  }    

  void setUserDetails(User user) {
    _userService.setUserDetails(user);
  }

  void setName(String name) {
    profile.user.name = name;
    setUserDetails(profile.user);
  }
  
  void setField(String field) {
    if (profile.user.field != field) {
      profile.user.field = field;
      profile.user.subfields = [];
      setUserDetails(profile.user);
      notifyListeners();
    }
  }

  Field getSelectedField() {
    Field selectedField;
    String selectedFieldName;
    final List<Field> fields = profile.fields;
    if (isNotEmpty(profile.user.field)) {
      selectedFieldName = profile.user.field;
    } else {
      selectedFieldName = fields[0].name;
    }
    for (final Field field in fields) {
      if (field.name == selectedFieldName) {
        selectedField = field;
        break;
      }
    }
    return selectedField;
  }   

  void setSubfield(String subfield, int index) {
    if (index < profile.user.subfields.length) {
      profile.user.subfields[index] = subfield;
    } else {
      profile.user.subfields.add(subfield);
    }
    setUserDetails(profile.user);
    notifyListeners();
  }  

  List<Subfield> getSubfields(int index) {
    final List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    final List<String> selectedSubfields = profile.user.subfields;
    final List<Subfield> filteredSubfields = [];
    if (subfields != null) {
      for (final Subfield subfield in subfields) {
        if (!selectedSubfields.contains(subfield.name) || 
            subfield.name == selectedSubfields[index]) {
          filteredSubfields.add(subfield);
        }
      }
    }
    return filteredSubfields;
  }

  int _getSelectedFieldIndex() {
    final List<Field> fields = profile.fields;
    final String selectedField = profile.user.field;
    return fields.indexWhere((Field field) => field.name == selectedField);
  }
  
  Subfield getSelectedSubfield(int index) {
    Subfield selectedSubfield;
    final List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    final List<String> selectedSubfields = profile.user.subfields;
    for (final Subfield subfield in subfields) {
      if (subfield.name == selectedSubfields[index]) {
        selectedSubfield = subfield;
        break;
      }
    }
    return selectedSubfield;
  }

  void addSubfield() {
    final List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    final List<String> selectedSubfields = profile.user.subfields;
    for (final Subfield subfield in subfields) {
      if (!selectedSubfields.contains(subfield.name)) {
        setSubfield(subfield.name, selectedSubfields.length+1);
        break;
      }
    }
    notifyListeners();
  }
  
  void deleteSubfield(int index) {
    profile.user.subfields.removeAt(index);
    setUserDetails(profile.user);
    notifyListeners();
  }

  void setIsAvailable(bool isAvailable) {
    profile.user.isAvailable = isAvailable;
    setUserDetails(profile.user);
    notifyListeners();
  }
  
  void addAvailability(Availability availability) {
    profile.user.availabilities.add(availability);
    _sortAvailabilities();
    _mergeAvailabilityTimes();
    setUserDetails(profile.user);
    notifyListeners();
  }

  void updateAvailability(int index, Availability newAvailability) {
    profile.user.availabilities[index] = newAvailability;
    _sortAvailabilities();
    _mergeAvailabilityTimes();
    setUserDetails(profile.user);
    notifyListeners();
  }

  void _sortAvailabilities() {
    profile.user.availabilities.sort((a, b) => Utils.convertTime12to24(a.time.from).compareTo(Utils.convertTime12to24(b.time.from)));
    profile.user.availabilities.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek)));
  }

  void _mergeAvailabilityTimes() {
    final List<Availability> availabilities = [];
    for (final String dayOfWeek in Utils.daysOfWeek) {
      final List<Availability> dayAvailabilities = [];
      for (final Availability availability in profile.user.availabilities) {
        if (availability.dayOfWeek == dayOfWeek) {
          dayAvailabilities.add(availability);
        }
      }
      final List<Availability> merged = [];
      int mergedLastTo = -1;
      _mergedAvailabilityLastShown = false;
      for (final Availability availability in dayAvailabilities) {
        if (merged.isNotEmpty) {
          mergedLastTo = Utils.convertTime12to24(merged.last.time.to);
        }
        final int availabilityFrom = Utils.convertTime12to24(availability.time.from);
        final int availabilityTo = Utils.convertTime12to24(availability.time.to);
        if (merged.isEmpty || mergedLastTo < availabilityFrom) {
          merged.add(availability);
        } else {
          if (mergedLastTo < availabilityTo) {
            _setAvailabilityMergedMessage(availability, merged);
            merged.last.time.to = availability.time.to;
          } else {
            _setAvailabilityMergedMessage(availability, merged);
          }
        }
      }
      availabilities.addAll(merged);
    }
    profile.user.availabilities = availabilities;
  }

  void _setAvailabilityMergedMessage(Availability availability, List<Availability> merged) {
    if (availabilityMergedMessage.isEmpty) {
      availabilityMergedMessage = 'The following availabilities have been merged:\n';
    }    
    if (!_mergedAvailabilityLastShown) {
      availabilityMergedMessage += merged.last.dayOfWeek + ' from ' + merged.last.time.from + ' to ' + merged.last.time.to + '\n';
      _mergedAvailabilityLastShown = true;
    }
    availabilityMergedMessage += availability.dayOfWeek + ' from ' + availability.time.from + ' to ' + availability.time.to + '\n';    
  }

  void resetAvailabilityMergedMessage() {
    availabilityMergedMessage = '';
  }

  bool isAvailabilityValid(Availability availability) {
    final int timeFrom = Utils.convertTime12to24(availability.time.from);
    final int timeTo = Utils.convertTime12to24(availability.time.to);
    return timeFrom < timeTo;
  }

  void deleteAvailability(int index) {
    profile.user.availabilities.removeAt(index);
    setUserDetails(profile.user);
    notifyListeners();
  }
  
  LessonsAvailability getLessonsAvailability() {
    return profile.user.lessonsAvailability;
  }
  
  void updateLessonsAvailability(LessonsAvailability lessonsAvailability) {
    profile.user.lessonsAvailability = lessonsAvailability;
    setUserDetails(profile.user);
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
