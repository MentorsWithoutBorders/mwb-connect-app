import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class NotificationsInformationDialog extends StatefulWidget {
  const NotificationsInformationDialog({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _NotificationsInformationDialogState();
}

class _NotificationsInformationDialogState extends State<NotificationsInformationDialog> {

  Widget _showNotificationsInformationDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showOkButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, right: 5.0),
      child: Center(
        child: Text(
          'notifications.label'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    String text = 'notifications.information'.tr();

    return Container(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 12.0,
          color: AppColors.DOVE_GRAY,
          height: 1.4
        )
      ),
    );
  }
  
  Widget _showOkButton() {
   return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            backgroundColor: AppColors.ALLPORTS,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0),
          ), 
          child: Text(
            'common.ok'.tr(),
            style: const TextStyle(color: Colors.white)
          ),
          onPressed: () async {
            Navigator.pop(context);
          }
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return _showNotificationsInformationDialog();
  }
}