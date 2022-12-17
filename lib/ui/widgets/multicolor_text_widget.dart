import 'package:flutter/material.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';

class MulticolorText extends StatelessWidget {
  final List<ColoredText> coloredTexts;

  MulticolorText({this.coloredTexts = const []});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        children: List<TextSpan>.generate(coloredTexts.length, (index) {
          return TextSpan(
            text: coloredTexts[index].text,
            style: TextStyle(
              fontSize: 12.0,
              color: coloredTexts[index].color,
              height: 1.4
            ),
          );
        })
      )
    );
  }
}