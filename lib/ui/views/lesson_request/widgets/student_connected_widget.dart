import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class StudentConnected extends StatefulWidget {
  const StudentConnected({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _StudentConnectedState();
}

class _StudentConnectedState extends State<StudentConnected> {

  Widget _showStudentConnectedCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.only(bottom: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), 
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              _showText(),
              _showCloseButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        'lesson_request.student_connected'.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.DOVE_GRAY,
          height: 1.5
        )
      ),
    ); 
  }

  Widget _showCloseButton() {
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ), 
          child: Text('common.close'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            print('Close');
          }
        ),
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    return _showStudentConnectedCard();
  }
}