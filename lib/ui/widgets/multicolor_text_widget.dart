import 'package:flutter/material.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';

class MulticolorText extends StatelessWidget {
  final List<ColoredText> coloredTexts;
  final bool? isSelectable;

  MulticolorText({this.coloredTexts = const [], this.isSelectable = false});

  @override
  Widget build(BuildContext context) {
    final TextSpan text = TextSpan(
      children: List<TextSpan>.generate(coloredTexts.length, (index) {
        return TextSpan(
          text: coloredTexts[index].text,
          style: TextStyle(
            fontSize: 13.0,
            color: coloredTexts[index].color,
            height: 1.4,
            fontWeight: coloredTexts[index].isBold == true ? FontWeight.bold : FontWeight.normal,
            fontStyle: coloredTexts[index].isItalic == true ? FontStyle.italic : FontStyle.normal
          ),
        );
      })
    );

  if (isSelectable == true) {
    return SelectableText.rich(
      text,
      textAlign: TextAlign.justify,
    );
  } else {
    return RichText(
      textAlign: TextAlign.justify,
      text: text,
    );
  }
  }
}