import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/services/root_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class RootViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final RootService _rootService = locator<RootService>();
  Lesson? nextLesson;

  String? getUserId() {
    return _storageService.userId;
  } 
  
  Future<void> getNextLesson() async {
    nextLesson = await _rootService.getNextLesson();
  }

  bool get isNextLesson => nextLesson != null && nextLesson?.id != null && nextLesson?.isCanceled != true;

}
