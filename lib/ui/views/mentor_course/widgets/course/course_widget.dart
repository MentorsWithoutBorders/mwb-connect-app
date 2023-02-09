import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/update_meeting_url_dialog_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/cancel_course_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/bullet_point_widget.dart';

class Course extends StatefulWidget {
  const Course({Key? key, @required this.text, @required this.students, @required this.meetingUrl, @required this.cancelText, @required this.onUpdateMeetingUrl, @required this.onCancel})
    : super(key: key); 

  final List<ColoredText>? text;
  final List<CourseStudent>? students;
  final String? meetingUrl;
  final String? cancelText;
  final Function(String)? onUpdateMeetingUrl;
  final Function(String?)? onCancel;

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
              _showStudents(),
              _showLink(),
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

  Widget _showStudents() {
    List<User>? students = widget.students;
    return Container(
      margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.SILVER)
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: students?.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40.0,
                  child: BulletPoint()
                ),
                Expanded(
                  child: RichText(
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.DOVE_GRAY,
                        height: 1.4
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${students?[index].name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        TextSpan(
                          text: ' - ${students?[index].organization?.name}'
                        )
                      ]
                    )
                  )
                )
              ]
            )
          );
        }
      )
    );
  }

  Widget _showLink() {
    String meetingUrl = widget.meetingUrl ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            'mentor_course.course_link'.tr(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.DOVE_GRAY
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 10.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  child: Text(
                    meetingUrl,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline
                    )
                  ),
                  onTap: () async => await _launchMeetingUrl()
                )
              ),
              _showEditLink()
            ]
          ),
        )
      ]
    );
  }

  Widget _showEditLink() {
    return InkWell(
      child: Container(
        height: 22.0,
        padding: const EdgeInsets.only(left: 5.0, right: 3.0),
        child: Image.asset(
          'assets/images/edit_icon.png'
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AnimatedDialog(
            widgetInside: UpdateMeetingUrlDialog(
              meetingUrl: widget.meetingUrl,
              onUpdate: widget.onUpdateMeetingUrl
            )
          )
        );
      }                 
    );
  }

  Future<void> _launchMeetingUrl() async {
    String meetingUrl = widget.meetingUrl as String;
    if (await canLaunchUrl(Uri.parse(meetingUrl))) {
      await launchUrl(
        Uri.parse(meetingUrl),
        mode: LaunchMode.externalApplication,
      );  
    } else {
      throw 'Could not launch $meetingUrl';
    }  
  }

  Widget _showCancelButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
      child: Center(
        child: Column(
          children: [
            Container(
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
                child: Text('common.cancel_course'.tr(), style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  _showCancelCourseDialog();
                }
              )
            )
          ]
        ),
      ),
    );
  }

  void _showCancelCourseDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: CancelCourseDialog(
          cancelText: widget.cancelText,
          onCancel: widget.onCancel
        )
      ),
    );    
  }

  @override
  Widget build(BuildContext context) {
    return _showCourseCard();
  }
}