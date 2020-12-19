import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';

class UsersViewModel extends ChangeNotifier {
  Api _api = locator<Api>();

  setUserDetails(User data) async {
    await _api.setDocument(path: 'profile', isForUser: true, data: data.toJson(), id: 'details');
  }

  Future<User> getUserDetails() async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'profile', isForUser: true, id: 'details');
    if (doc.exists) {
      return User.fromMap(doc.data, doc.documentID);
    } else {
      return User();
    }
  }  
}
