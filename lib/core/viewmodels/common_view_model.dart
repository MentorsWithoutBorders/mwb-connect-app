import 'package:flutter/material.dart';

class CommonViewModel extends ChangeNotifier {
  double dialogInputHeight = 0.0;

  setDialogInputHeight(double height) {
    dialogInputHeight = height;
    notifyListeners();
  }   
}
