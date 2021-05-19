import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service_old.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';

class ProfileService {
  final Api _api = locator<Api>();

  Future<List<Field>> getFields() async {
    final QuerySnapshot result = await _api.getDataCollection(path: 'fields', isForUser: false);
    return result.docs
        .map((QueryDocumentSnapshot doc) => Field.fromMap(doc.data()))
        .toList();
  }

  Future<void> addField(Field field) async {
    await _api.addDocument(path: 'fields', isForUser: false, data: field.toJson());
  }
}
