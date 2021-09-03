import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/cancel_lesson_recurrence_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/cancel_next_lesson_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class CancelNextLessonOptionsDialog extends StatefulWidget {
  const CancelNextLessonOptionsDialog({Key? key, @required this.context})
    : super(key: key);  

  final BuildContext? context;  

  @override
  State<StatefulWidget> createState() => _CancelNextLessonOptionsDialogState();
}

class _CancelNextLessonOptionsDialogState extends State<CancelNextLessonOptionsDialog> {

  Widget _showCancelNextLessonOptionsDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 25.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showOptions()
        ]
      )
    );
  }

  Widget _showTitle() {
    String title = 'common.cancel_recurring_lesson'.tr();
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showOptions() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Wrap(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.BERMUDA_GRAY,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ),             
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => const AnimatedDialog(
                    widgetInside: CancelNextLessonDialog()
                  ),
                ); 
              },
              child: Text('common.cancel_only_next_lesson'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.MONZA,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: CancelLessonRecurrenceDialog()
                  ),
                );                      
              },
              child: Text('common.cancel_entire_lesson_recurrence'.tr(), style: const TextStyle(color: Colors.white))
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: InkWell(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(                      
                  child: Text('common.abort'.tr(), style: const TextStyle(color: Colors.grey))
                )
              ),
              onTap: () {
                Navigator.pop(widget.context!);
              },
            ),
          )
        ]
      )
    );
  }  

  @override
  Widget build(BuildContext context) {
    return _showCancelNextLessonOptionsDialog();
  }
}

