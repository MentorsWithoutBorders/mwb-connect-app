import 'dart:async';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';

class ProfileService {
  final ApiService _api = locator<ApiService>();

  Future<List<Field>> getFields() async {
    dynamic response = await _api.getHTTP(url: '/fields');
    List<Field> fields = [];
    if (response != null) {
      fields = List<Field>.from(response.map((model) => Field.fromJson(model)));
    }
    return fields;
  }
}
