import 'package:flutter/material.dart';

class CommonViewModel extends ChangeNotifier {
  double dialogInputHeight = 0.0;
  dynamic location;

  void setDialogInputHeight(double height) {
    dialogInputHeight = height;
    notifyListeners();
  }   
}
