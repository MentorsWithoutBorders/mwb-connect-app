import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/cancel_next_lesson_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/cancel_course_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class CancelLessonsOptionsDialog extends StatefulWidget {
  const CancelLessonsOptionsDialog({Key? key, @required this.cancelCourseText, @required this.onCancelNextLesson, @required this.onCancelCourse, @required this.context})
    : super(key: key);
    
  final String? cancelCourseText;
  final Function(String?)? onCancelNextLesson;
  final Function(String?)? onCancelCourse;
  final BuildContext? context;

  @override
  State<StatefulWidget> createState() => _CancelLessonsOptionsDialogState();
}

class _CancelLessonsOptionsDialogState extends State<CancelLessonsOptionsDialog> {

  Widget _showCancelLessonsOptionsDialog() {
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
    String title = 'common.cancel_lessons'.tr();
    return Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18.0,
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
                backgroundColor: AppColors.BERMUDA_GRAY,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ),             
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: CancelNextLessonDialog(
                      onCancel: widget.onCancelNextLesson
                    )
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
                backgroundColor: AppColors.MONZA,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                )
              ),
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: CancelCourseDialog(
                      cancelText: widget.cancelCourseText,
                      onCancel: widget.onCancelCourse,
                    )
                  ),
                );                      
              },
              child: Text('common.cancel_course'.tr(), style: const TextStyle(color: Colors.white))
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
    return _showCancelLessonsOptionsDialog();
  }
}

