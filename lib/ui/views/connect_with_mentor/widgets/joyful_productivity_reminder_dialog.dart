import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/tutorials/tutorial_view.dart';

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
    String firstPart = 'joyful_productivity_reminder.text.first_part'.tr();
    String secondPart = 'joyful_productivity_reminder.text.second_part'.tr();
    String thirdPart = 'joyful_productivity_reminder.text.third_part'.tr();
    String fourthPart = 'joyful_productivity_reminder.text.fourth_part'.tr();
    String superFocusMethod = 'joyful_productivity_reminder.text.super_focus_method'.tr();
    String fifthPart = 'joyful_productivity_reminder.text.fifth_part'.tr();
    String quickDeepRelaxation = 'joyful_productivity_reminder.text.quick_deep_relaxation'.tr();
    String sixthPart = 'joyful_productivity_reminder.text.sixth_part'.tr();
    String seventhPart = 'joyful_productivity_reminder.text.seventh_part'.tr();
    String list = 'joyful_productivity_reminder.text.list'.tr();

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Scrollbar(
        controller: _scrollController, 
        isAlwaysShown: true, 
        child: SingleChildScrollView(
          controller: _scrollController,     
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppColors.DOVE_GRAY,
                        height: 1.5
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: firstPart
                        ),
                        TextSpan(
                          text: ' ' + secondPart + ' ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        TextSpan(
                          text: thirdPart + ' ',
                        ),
                        TextSpan(
                          text: fourthPart + ' ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        TextSpan(
                          text: superFocusMethod,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: AppColors.TANGO
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            _goToTutorialSuperFocusMethod();
                          }
                        ),
                        TextSpan(
                          text:  ' ' + fifthPart + ' ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        TextSpan(
                          text: quickDeepRelaxation,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: AppColors.TANGO
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            _goToTutorialQuickDeepRelaxationMethod();
                          }
                        ),
                        TextSpan(
                          text: ' ' + sixthPart + ' ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        TextSpan(
                          text: seventhPart + ' '
                        )
                      ]
                    )
                  ),
                ),
                HtmlWidget(list)
              ]
            ),
          )
        )
      ),
    );
  }

  void _goToTutorialSuperFocusMethod() {
    Navigator.push(context, MaterialPageRoute<TutorialView>(builder: (_) => TutorialView(type: 'super_focus_method')));    
  }

  void _goToTutorialQuickDeepRelaxationMethod() {
    Navigator.push(context, MaterialPageRoute<TutorialView>(builder: (_) => TutorialView(type: 'relaxation_method', section: 'how_to_relax')));    
  }  
  
  Widget _showGotItButton() {
   return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.BERMUDA_GRAY,
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