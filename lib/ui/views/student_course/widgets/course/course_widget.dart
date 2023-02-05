import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/widgets/course/cancel_course_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class Course extends StatefulWidget {
  const Course({Key? key, @required this.mentor, @required this.partnerMentor, @required this.text, @required this.onCancel})
    : super(key: key);
    
  final CourseMentor? mentor;
  final CourseMentor? partnerMentor;
  final List<ColoredText>? text;
  final Function(String)? onCancel;

  @override
  State<StatefulWidget> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  Widget _showCourseCard() {
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
              _showCancelButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 15.0),
          child: MulticolorText(
            coloredTexts: widget.text as List<ColoredText>
          )
        ),
        _showMeetingUrls()
      ]
    );
  }

  Widget _showMeetingUrls() {
    String or = 'common.or'.tr();
    return Wrap(
      children: [
        _showMeetingUrl(widget.mentor as CourseMentor),
        if (widget.partnerMentor != null) Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
          child: Center(
            child: Text(
              or,
              style: const TextStyle(
                fontSize: 13.0,
                fontStyle: FontStyle.italic
              )
            )
          )
        ),
        if (widget.partnerMentor != null) _showMeetingUrl(widget.partnerMentor as CourseMentor)
      ]
    );
  }

  Widget _showMeetingUrl(CourseMentor mentor) {
    String meetingUrl = mentor.meetingUrl ?? '';
    String mentorName = mentor.name ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
      child: Center(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(
                mentorName + ': ',
                style: const TextStyle(
                  fontSize: 13.0,
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
              onTap: () async => await _launchMeetingUrl(meetingUrl)
            ),
          ],
        )
      )
    );
  }  

  Future<void> _launchMeetingUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );  
    } else {
      throw 'Could not launch $url';
    }
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
          child: Text('student_course.cancel_course'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AnimatedDialog(
                widgetInside: CancelCourseDialog(
                  onCancel: widget.onCancel
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