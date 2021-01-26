import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';

class ProfileService {
  Api _api = locator<Api>();

  Future<List<Field>> getFields() async {
    QuerySnapshot result = await _api.getDataCollection(path: 'fields', isForUser: false);
    return result.documents
        .map((doc) => Field.fromMap(doc.data))
        .toList();
  }

}
