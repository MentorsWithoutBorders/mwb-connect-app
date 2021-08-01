import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({Key key, this.text, this.shouldReload})
    : super(key: key);

  final String text;
  final bool shouldReload;
    
  @override
  State<StatefulWidget> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {

  Widget _showNotificationDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    String title = 'common.notification'.tr();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    String text = widget.text != null ? widget.text : '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.DOVE_GRAY,
          height: 1.5
        )
      )
    );
  }
  
  Widget _showButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: AppColors.PACIFIC_BLUE,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          padding: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 5.0),
        ),
        child: Text(
          'common.ok'.tr(),
          style: const TextStyle(color: Colors.white)
        ),
        onPressed: () async {
          if (widget.shouldReload) {
            _reloadApp();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  } 

  void _reloadApp() {
    Phoenix.rebirth(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return _showNotificationDialog();
  }
}