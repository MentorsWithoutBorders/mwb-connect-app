import 'dart:async';
import 'package:dio/dio.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';

class ProfileService {
  final ApiService _api = locator<ApiService>();

  Future<List<Field>> getFields() async {
    Response response = await _api.getHTTP(url: '/fields');
    List<Field> fields = List<Field>.from(response.data.map((model) => Field.fromJson(model)));
    return fields;
  }

  Future<void> addField(Field field) async {
    // await _api.addDocument(path: 'fields', isForUser: false, data: field.toJson());
  }
}
