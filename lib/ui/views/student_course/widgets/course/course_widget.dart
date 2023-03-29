import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/course/course_notes_view.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/course/cancel_lessons_options_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class Course extends StatefulWidget {
  const Course({Key? key, @required this.mentorNextLesson, @required this.text, @required this.whatsAppGroupUrl, @required this.onCancelNextLesson, @required this.onCancelCourse})
    : super(key: key);
    
  final CourseMentor? mentorNextLesson;
  final List<ColoredText>? text;
  final String? whatsAppGroupUrl;
  final Function(String?)? onCancelNextLesson;
  final Function(String?)? onCancelCourse;

  @override
  State<StatefulWidget> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  
  Widget _showCourseCard() {
    bool isWhatsAppGroupUrl = widget.whatsAppGroupUrl != null && widget.whatsAppGroupUrl!.isNotEmpty;
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
              _showMeetingUrl(),
              if (isWhatsAppGroupUrl) _showWhatsAppGroupUrl(),
              _showCourseNotesButton(),
              _showCancelButton()
            ]
          )
        ),
      ),
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

  Widget _showMeetingUrl() {
    String meetingUrl = widget.mentorNextLesson?.meetingUrl ?? '';
    String mentorName = widget.mentorNextLesson?.name ?? '';
    bool isWhatsAppGroupUrl = widget.whatsAppGroupUrl != null && widget.whatsAppGroupUrl!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.only(bottom: 7.0),
      margin: isWhatsAppGroupUrl ? const EdgeInsets.only(bottom: 12.0) : const EdgeInsets.only(bottom: 0.0),
      decoration: isWhatsAppGroupUrl ? BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: AppColors.MYSTIC),
        )
      ) : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  mentorName + ': ',
                  style: const TextStyle(
                    color: AppColors.DOVE_GRAY,
                    fontSize: 13.0
                  )
                )
              ),
              InkWell(
                child: Text(
                  meetingUrl,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline
                  )
                ),
                onTap: () async => await Utils.launchAppUrl(meetingUrl)
              ),
            ],
          )
        )
      )
    );
  }

  Widget _showWhatsAppGroupUrl() {
    String whatsAppGroupUrl = widget.whatsAppGroupUrl ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                'common.course_whatsapp_group_link'.tr(),
                style: const TextStyle(
                  color: AppColors.DOVE_GRAY,
                  fontSize: 13.0
                )
              )
            ),
            InkWell(
              child: Text(
                whatsAppGroupUrl,
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline
                )
              ),
              onTap: () async => await Utils.launchAppUrl(whatsAppGroupUrl)
            ),
          ],
        )
      )
    );
  }

  Widget _showCourseNotesButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 30.0,
              margin: const EdgeInsets.only(bottom: 5.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 1.0,
                  primary: AppColors.ALLPORTS,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
                ), 
                child: Text('student_course.see_course_notes'.tr(), style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  _goToCourseNotes();
                }
              )
            )
          ]
        ),
      ),
    );
  }
  
  void _goToCourseNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseNotesView()
      )
    ); 
  }  

  Widget _showCancelButton() {
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
          child: Text('common.cancel_lessons'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AnimatedDialog(
                widgetInside: CancelLessonsOptionsDialog(
                  onCancelNextLesson: widget.onCancelNextLesson,
                  onCancelCourse: widget.onCancelCourse,
                  context: context
                )
              )
            ); 
          }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showCourseCard();
  }
}