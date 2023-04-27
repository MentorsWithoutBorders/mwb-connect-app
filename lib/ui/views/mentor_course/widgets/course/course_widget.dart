import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/next_lesson_mentor_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/course_notes_view.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/set_meeting_url_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/set_whatsapp_group_dialog_url_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/cancel_lessons_options_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/bullet_point_widget.dart';

class Course extends StatefulWidget {
  const Course(
      {Key? key,
      @required this.course,
      @required this.nextLesson,
      @required this.meetingUrl,
      @required this.text,
      @required this.cancelCourseText,
      @required this.onSetMeetingUrl,
      @required this.onSetWhatsAppGroupUrl,
      @required this.onUpdateNotes,
      @required this.onGoToPartnershipSchedule,
      @required this.onCancelNextLesson,
      @required this.onCancelCourse})
      : super(key: key);

  final CourseModel? course;
  final NextLessonMentor? nextLesson;
  final String? meetingUrl;
  final List<ColoredText>? text;
  final String? cancelCourseText;
  final Function(String)? onSetMeetingUrl;
  final Function(String)? onSetWhatsAppGroupUrl;
  final Function(String?)? onUpdateNotes;
  final Function? onGoToPartnershipSchedule;
  final Function(String?)? onCancelNextLesson;
  final Function(String?)? onCancelCourse;

  @override
  State<StatefulWidget> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  Widget _showCourseCard() {
    int mentorsCount = widget.course?.mentors?.length ?? 0;
    bool isMeetingUrl = widget.meetingUrl != null && widget.meetingUrl!.isNotEmpty;
    bool isWhatsAppGroupUrl = widget.course != null && widget.course?.whatsAppGroupUrl != null && widget.course!.whatsAppGroupUrl!.isNotEmpty;
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
            child: Wrap(children: [
              _showText(),
              _showStudents(),
              if (isMeetingUrl) _showMeetingLink(),
              if (isWhatsAppGroupUrl) _showWhatsAppGroupLink(),
              if (!isWhatsAppGroupUrl) _showSetWhatsAppGroupLinkButton(),
              _showUpdateCourseNotesButton(),
              if (mentorsCount > 1) _showUpdatePartnershipScheduleButton(),
              _showCancelButton()
            ])),
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
    List<User>? students = widget.nextLesson?.students;
    return Container(
      margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 5.0),
      decoration: BoxDecoration(border: Border.all(color: AppColors.SILVER)),
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
                Container(width: 40.0, child: BulletPoint()),
                Expanded(
                  child: RichText(
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13.0, 
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

  Widget _showMeetingLink() {
    int mentorsCount = widget.course?.mentors?.length ?? 0;
    String text = mentorsCount > 1 ? 'mentor_course.course_meeting_your_link'.tr() : 'mentor_course.course_meeting_link'.tr();
    String meetingUrl = widget.meetingUrl ?? '';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            text,
            style: const TextStyle(fontSize: 13.0, color: AppColors.DOVE_GRAY),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 20.0),
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
                  onTap: () async => await Utils.launchAppUrl(meetingUrl)
                )
              ),
              _showEditMeetingLink()
            ]
          ),
        )
      ]
    );
  }

  Widget _showEditMeetingLink() {
    return InkWell(
      child: Container(
        height: 22.0,
        padding: const EdgeInsets.only(left: 5.0, right: 3.0),
        child: Image.asset('assets/images/edit_icon.png'),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AnimatedDialog(
            widgetInside: SetMeetingUrlDialog(
              meetingUrl: widget.meetingUrl, 
              isUpdate: true, 
              onSet: widget.onSetMeetingUrl
            )
          )
        );
      }
    );
  }

  Widget _showWhatsAppGroupLink() {
    String whatsAppGroupUrl = widget.course?.whatsAppGroupUrl ?? '';
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          'common.course_whatsapp_group_link'.tr(),
          style: const TextStyle(fontSize: 13.0, color: AppColors.DOVE_GRAY),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 15.0),
        child: Row(children: [
          Expanded(
            child: InkWell(
              child: Text(
                whatsAppGroupUrl, 
                style: const TextStyle(
                  fontSize: 13.0, 
                  fontWeight: FontWeight.bold, 
                  decoration: TextDecoration.underline
                )
              ),
              onTap: () async => await Utils.launchAppUrl(whatsAppGroupUrl)
            )
          ),
          _showEditWhatsAppGroupLink()
        ]),
      )
    ]);
  }

  Widget _showEditWhatsAppGroupLink() {
    return InkWell(
      child: Container(
        height: 22.0,
        padding: const EdgeInsets.only(left: 5.0, right: 3.0),
        child: Image.asset('assets/images/edit_icon.png'),
      ),
      onTap: () {
        _showSetWhatsAppGroupLinkDialog(isUpdate: true);
      }
    );
  }

  void _showSetWhatsAppGroupLinkDialog({bool isUpdate = false}) {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: SetWhatsAppGroupUrlDialog(
          whatsAppGroupUrl: widget.course?.whatsAppGroupUrl, 
          isUpdate: isUpdate, 
          onSet: widget.onSetWhatsAppGroupUrl
        )
      )
    );
  }

  Widget _showSetWhatsAppGroupLinkButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: Column(children: [
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(bottom: 5.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 1.0,
                backgroundColor: AppColors.ALLPORTS,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
              ),
              child: Text(
                'mentor_course.add_whatsapp_group'.tr(), 
                style: const TextStyle(color: Colors.white)
              ),
              onPressed: () {
                _showSetWhatsAppGroupLinkDialog();
              }
            )
          )
        ]),
      ),
    );
  }

  Widget _showUpdateCourseNotesButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: Column(children: [
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(bottom: 5.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 1.0,
                backgroundColor: AppColors.ALLPORTS,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
              ),
              child: Text(
                'mentor_course.update_course_notes'.tr(), 
                style: const TextStyle(color: Colors.white)
              ),
              onPressed: () {
                _goToUpdateCourseNotes();
              }
            )
          )
        ]),
      ),
    );
  }

  void _goToUpdateCourseNotes() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CourseNotesView(courseNotes: widget.course?.notes, onUpdate: widget.onUpdateNotes)));
  }

  Widget _showUpdatePartnershipScheduleButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 30.0,
              margin: const EdgeInsets.only(bottom: 5.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 1.0,
                  backgroundColor: AppColors.ALLPORTS,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
                ),
                child: Text(
                  'mentor_course.update_partnership_schedule'.tr(), 
                  style: const TextStyle(color: Colors.white)
                ),
                onPressed: () {
                  _goToUpdatePartnershipSchedule();
                }
              )
            )
          ]
        ),
      ),
    );
  }

  void _goToUpdatePartnershipSchedule() {
    widget.onGoToPartnershipSchedule!();
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
                  backgroundColor: AppColors.MONZA,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
                ),
                child: Text(
                  'common.cancel_lessons'.tr(), 
                  style: const TextStyle(color: Colors.white)
                ),
                onPressed: () {
                  _showCancelCourseDialog();
                }
              )
            )
          ]
        )
      )
    );
  }

  void _showCancelCourseDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: CancelLessonsOptionsDialog(
          cancelCourseText: widget.cancelCourseText,
          onCancelNextLesson: widget.onCancelNextLesson,
          onCancelCourse: widget.onCancelCourse,
          context: context
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showCourseCard();
  }
}
