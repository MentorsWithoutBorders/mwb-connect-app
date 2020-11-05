import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class BackgroundGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.ALLPORTS, AppColors.MINT_GREEN]
          )
        ),
      ),
    );  
  }
}
