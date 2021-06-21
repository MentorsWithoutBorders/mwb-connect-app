import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class BulletPoint extends StatelessWidget {
  const BulletPoint({Key key})
    : super(key: key); 

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6.0,
      height: 6.0,
      decoration: BoxDecoration(
        color: AppColors.SILVER,
        shape: BoxShape.circle,
      )
    );
  }
}
