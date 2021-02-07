import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class ProfileViewModel extends ChangeNotifier {
  UserService _userService = locator<UserService>();
  ProfileService _profileService = locator<ProfileService>();
  Profile profile;

  Future<User> getUserDetails() async {
    return await _userService.getUserDetails();
  }

  Future<List<Field>> getFields() async {
    return await _profileService.getFields();
  }  

  setUserDetails(User user) async {
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

  void setSubfield(String subfield, int index) {
    profile.user.subfields[index] = subfield;
    setUserDetails(profile.user);
    notifyListeners();
  }  

  List<Subfield> getSubfields(int index) {
    List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    List<String> selectedSubfields = profile.user.subfields;
    List<Subfield> filteredSubfields = List();
    if (subfields != null) {
      for (var subfield in subfields) {
        if (!selectedSubfields.contains(subfield.name) || 
            subfield.name == selectedSubfields[index]) {
          filteredSubfields.add(subfield);
        }
      }
    }
    return filteredSubfields;
  }

  int _getSelectedFieldIndex() {
    List<Field> fields = profile.fields;
    String selectedField = profile.user.field;
    return fields.indexWhere((field) => field.name == selectedField);
  }
  
  Subfield getSelectedSubfield(int index) {
    String selectedSubfieldName;
    Subfield selectedSubfield;
    List<Subfield> subfields = profile.fields[_getSelectedFieldIndex()].subfields;
    List<String> selectedSubfields = profile.user.subfields;
    if (isNotEmpty(selectedSubfields[index])) {
      selectedSubfieldName = selectedSubfields[index];
    } else {
      selectedSubfieldName = subfields[0].name;
    }
    for (var subfield in subfields) {
      if (subfield.name == selectedSubfieldName) {
          selectedSubfield = subfield;
        break;
      }
    }
    return selectedSubfield;
  }  
}
