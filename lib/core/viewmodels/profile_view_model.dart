import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:easy_localization/easy_localization.dart';
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
  double scrollOffset = 0;

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

  void setSubfield(Subfield subfield, int index) {
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
    final List<Subfield> userSubfields = profile.user.subfields;
    final List<Subfield> filteredSubfields = [];
    if (subfields != null) {
      for (final Subfield subfield in subfields) {
        if (!_containsSubfield(userSubfields, subfield) || 
            subfield.name == userSubfields[index].name) {
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
  
  Subfield getSelectedSubfield(int index) {
    Subfield selectedSubfield;
    final List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    final List<Subfield> userSubfields = profile.user.subfields;
    for (final Subfield subfield in subfields) {
      if (subfield.name == userSubfields[index].name) {
        selectedSubfield = subfield;
        break;
      }
    }
    return selectedSubfield;
  }

  void addSubfield() {
    final List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    final List<Subfield> userSubfields = profile.user.subfields;
    for (final Subfield subfield in subfields) {
      if (!_containsSubfield(userSubfields, subfield)) {
        setSubfield(Subfield(name: subfield.name), userSubfields.length+1);
        break;
      }
    }
    notifyListeners();
  }

  void setScrollOffset(double positionDy, double screenHeight, double statusBarHeight) {
    final double height = screenHeight - statusBarHeight - 340;
    if (positionDy >= height) {
      scrollOffset = 100;
    } else {
      scrollOffset = positionDy - height;
    }
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

  void setAvailableFrom(DateTime availableFrom) {
    profile.user.availableFrom = availableFrom;
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
      availabilityMergedMessage = 'profile.availabilities_merged'.tr() + '\n';
    }    
    if (!_mergedAvailabilityLastShown) {
      availabilityMergedMessage += merged.last.dayOfWeek + ' ' + 'common.from'.tr() + ' ' + merged.last.time.from + ' ' + 'common.to'.tr() + ' ' + merged.last.time.to + '\n';
      _mergedAvailabilityLastShown = true;
    }
    availabilityMergedMessage += availability.dayOfWeek + ' ' + 'common.from'.tr() + ' ' + availability.time.from + ' ' + 'common.to'.tr() + ' ' + availability.time.to + '\n';    
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

  void updateLessonsAvailability(LessonsAvailability lessonsAvailability) {
    profile.user.lessonsAvailability = lessonsAvailability;
    setUserDetails(profile.user);
    notifyListeners();
  }
    
  String getPeriodUnitPlural(String unit, int number) {
    String unitPlural;
    if (Utils.periodUnits.contains(unit)) {
      unitPlural = plural(unit, number);
    } else {
      if (Utils.getPeriodUnitsPlural().contains(unit)) {
        unitPlural = plural(Utils.periodUnits[Utils.getPeriodUnitsPlural().indexOf(unit)], number);
      }
    }
    return unitPlural;    
  }

  String getPeriodUnitSingular(String unit, int number) {
    String unitSingular;
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
