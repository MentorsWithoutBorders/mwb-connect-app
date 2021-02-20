import 'package:flutter/material.dart';
import 'dart:convert';

class JsonAssetLoader {
  var jsonFile;

  JsonAssetLoader({json}):
    jsonFile = json;
  
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) async {
    return json.decode(jsonFile);
  }
}