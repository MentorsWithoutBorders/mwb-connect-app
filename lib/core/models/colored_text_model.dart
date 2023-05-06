import 'package:flutter/material.dart';

class ColoredText {
  final String? text;
  final Color? color;
  final bool? isBold;
  final bool? isItalic;

  ColoredText({@required this.text, @required this.color, this.isBold, this.isItalic});
}