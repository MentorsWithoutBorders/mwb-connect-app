import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class Label extends StatelessWidget {
  const Label({Key key, @required this.text})
    : super(key: key); 
  
  final String text;

  Widget _showLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.0,
          color: AppColors.DOVE_GRAY
        )
      )
    );
  }  

  @override
  Widget build(BuildContext context) {
    return _showLabel();
  }
}