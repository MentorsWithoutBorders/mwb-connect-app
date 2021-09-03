import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';

class ProfileService {
  final ApiService _api = locator<ApiService>();

  Future<List<Field>> getFields() async {
    http.Response response = await _api.getHTTP(url: '/fields');
    var json = jsonDecode(response.body);
    List<Field> fields = List<Field>.from(json.map((model) => Field.fromJson(model)));
    return fields;
  }
}
