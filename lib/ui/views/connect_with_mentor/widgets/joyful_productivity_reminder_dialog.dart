import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class JoyfulProductivityReminderDialog extends StatefulWidget {
  const JoyfulProductivityReminderDialog({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _JoyfulProductivityReminderDialogState();
}

class _JoyfulProductivityReminderDialogState extends State<JoyfulProductivityReminderDialog> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _showJoyfulProductivityReminderDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 15.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showGotItButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, right: 5.0),
      child: Center(
        child: Text(
          'joyful_productivity_reminder.title'.tr(),
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
    String text = 'joyful_productivity_reminder.text'.tr();

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Scrollbar(
        controller: _scrollController,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: _scrollController,     
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 15.0),
            child: HtmlWidget(text),
          )
        )
      ),
    );
  }

  Widget _showGotItButton() {
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
            'joyful_productivity_reminder.got_it'.tr(),
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
    return _showJoyfulProductivityReminderDialog();
  }
}