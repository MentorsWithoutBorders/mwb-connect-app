import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';

class UsersViewModel extends ChangeNotifier {
  Api _api = locator<Api>();

  setUser(User data) async {
    await _api.setDocument(path: 'details', isForUser: true, data: data.toJson(), id: 'personal');
  }

  Future<User> getUserDetails() async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'details', isForUser: true, id: 'personal');
    if (doc.exists) {
      return User.fromMap(doc.data, doc.documentID);
    } else {
      return User();
    }
  }  
}
