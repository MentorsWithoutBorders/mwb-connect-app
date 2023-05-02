import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_result_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/error_model.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';

class JoinCourseDialog extends StatefulWidget {
  const JoinCourseDialog({Key? key, @required this.id, @required this.text, @required this.onJoin})
    : super(key: key);
    
  final String? id;
  final List<ColoredText>? text;
  final Function(String)? onJoin;

  @override
  State<StatefulWidget> createState() => _JoinCourseDialogState();
}

class _JoinCourseDialogState extends State<JoinCourseDialog> {
  bool _isJoiningCourse = false;  
  
  Widget _showJoinCourseDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Text(
          'student_course.join_course'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        ),
      )
    );
  }

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 15.0),
      child: MulticolorText(
        coloredTexts: widget.text as List<ColoredText>
      )
    );
  }

  Widget _showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
            child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 12.0)
          ), 
          onPressed: () async {
            await _joinCourse();
          },
          child: !_isJoiningCourse ? Text(
            'student_course.join_course'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 74.0,
            height: 16.0,
            child: ButtonLoader()
          )
        )
      ]
    ); 
  }

  Future<void> _joinCourse() async {
    setState(() {
      _isJoiningCourse = true;
    });
    try {
      CourseResult? courseResult = await widget.onJoin!(widget.id as String);
      Navigator.pop(context, courseResult);
    } on ErrorModel catch (error) {
      String? message = error.message;
      Navigator.pop(context);
      _showError(message);
    }
  }

  void _showError(String? message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AnimatedDialog(
          widgetInside: NotificationDialog(
            text: message,
            buttonText: 'common.ok'.tr()
          )
        );
      }
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return _showJoinCourseDialog();
  }
}