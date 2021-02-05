import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';

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
 
}
