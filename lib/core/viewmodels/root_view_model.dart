import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class RootViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();

  String? getUserId() {
    return _storageService.userId;
  }  
}
