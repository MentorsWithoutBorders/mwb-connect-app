import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/lesson_note_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/lessons_notes_dialog.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/lesson_guide_dialog.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/add_lessons_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/change_url_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/cancel_next_lesson_options_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/cancel_next_lesson_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/bullet_point_widget.dart';

class NextLesson extends StatefulWidget {
  const NextLesson({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _NextLessonState();
}

class _NextLessonState extends State<NextLesson> {
  LessonRequestViewModel? _lessonRequestProvider;
  String _url = '';

  Widget _showNextLessonCard() {
    if (_lessonRequestProvider?.isNextLesson == false) {
      return SizedBox.shrink();
    }
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
              _showGuide(),
              _showButtons()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    if (_lessonRequestProvider?.isNextLesson == false) {
      return SizedBox.shrink();
    }
    Lesson? nextLesson = _lessonRequestProvider?.nextLesson;
    if (nextLesson?.endRecurrenceDateTime == null || nextLesson?.dateTime == nextLesson?.endRecurrenceDateTime) {
      return _showSingleLessonText(nextLesson);
    } else {
      return _showRecurringLessonText(nextLesson);
    }
  }  

  Widget _showSingleLessonText(Lesson? nextLesson) {
    DateTime nextLessonDateTime = nextLesson?.dateTime as DateTime;
    int daysSinceStart = nextLesson?.daysSinceStart ?? 0;
    bool isAvailableForOtherStudents = daysSinceStart <= 21;
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');
    DateTime now = DateTime.now();
    String subfield = nextLesson?.subfield?.name?.toLowerCase() as String;
    String article = Utils.getIndefiniteArticle(subfield);
    String date = dateFormat.format(nextLessonDateTime);
    String time = timeFormat.format(nextLessonDateTime);
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String studentPlural = plural('student', nextLesson?.students?.length as int);
    String text = 'lesson_request.lesson_scheduled'.tr(args: [article, subfield, date, time, timeZone, studentPlural]);
    String firstPart = text.substring(0, text.indexOf(subfield));
    String secondPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(date));
    String thirdPart = text.substring(text.indexOf(timeZone) + timeZone.length, text.indexOf(' ('));
    String fourthPart = text.substring(text.indexOf(' ('));
    _url = nextLesson?.meetingUrl as String;

    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 15.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13.0,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: firstPart
            ),
            TextSpan(
              text: subfield
            ),
            TextSpan(
              text: secondPart
            ),
            TextSpan(
              text: 'common.on'.tr() + ' '
            ),
            TextSpan(
              text: date,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: ' ' + at + ' '
            ),
            TextSpan(
              text: time + ' ' + timeZone,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: thirdPart
            ),
            if (!isAvailableForOtherStudents) TextSpan(
              text: ':'
            ),
            if (isAvailableForOtherStudents) TextSpan(
              text: fourthPart,
              style: const TextStyle(
                fontStyle: FontStyle.italic
              )
            ),
            if (isAvailableForOtherStudents) TextSpan(
              text: ' ' + 'common.your_profile'.tr(),
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontStyle: FontStyle.italic
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                Navigator.push(context, MaterialPageRoute<ProfileView>(builder: (_) => ProfileView()));
              } 
            ),
            if (isAvailableForOtherStudents) TextSpan(
              text: '):',
              style: const TextStyle(
                fontStyle: FontStyle.italic
              )
            )
          ]
        )
      ),
    );
  }


  Widget _showRecurringLessonText(Lesson? nextLesson) {
    DateTime nextLessonDateTime = nextLesson?.dateTime as DateTime;
    int daysSinceStart = nextLesson?.daysSinceStart ?? 0;
    bool isAvailableForOtherStudents = daysSinceStart <= 21;
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');
    DateTime now = DateTime.now();
    String subfield = nextLesson?.subfield?.name?.toLowerCase() as String;
    String lessonDate = dateFormat.format(nextLessonDateTime);
    String dayOfWeek = lessonDate.substring(0, lessonDate.indexOf(','));    
    String time = timeFormat.format(nextLessonDateTime);
    String timeZone = now.timeZoneName;
    String endRecurrenceDate = dateFormat.format(_lessonRequestProvider?.getCorrectEndRecurrenceDate() as DateTime);
    endRecurrenceDate = endRecurrenceDate.substring(endRecurrenceDate.indexOf(',') + 2);    
    String at = 'common.at'.tr();
    String until = 'common.until'.tr();
    String studentPlural = plural('student', nextLesson?.students?.length as int);
    String text = 'lesson_request.lesson_scheduled_recurring'.tr(args: [subfield, dayOfWeek, endRecurrenceDate, lessonDate, time, timeZone, studentPlural]);
    String firstPart = text.substring(0, text.indexOf(dayOfWeek));
    String secondPart = text.substring(text.indexOf(endRecurrenceDate) + endRecurrenceDate.length, text.indexOf(lessonDate));
    String thirdPart = text.substring(text.indexOf(timeZone) + timeZone.length, text.indexOf('('));
    String fourthPart = text.substring(text.indexOf('('));
    _url = nextLesson?.meetingUrl as String;

    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 15.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13.0,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: firstPart
            ),
            TextSpan(
              text: dayOfWeek,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: ' ' + until + ' '
            ),
            TextSpan(
              text: endRecurrenceDate,
              style: const TextStyle(
                color: AppColors.TANGO
              )
            ),
            TextSpan(
              text: secondPart
            ),
            TextSpan(
              text: 'common.on'.tr() + ' '
            ),
            TextSpan(
              text: lessonDate,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: ' ' + at + ' '
            ),
            TextSpan(
              text: time + ' ' + timeZone,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: thirdPart
            ),
            if (!isAvailableForOtherStudents) TextSpan(
              text: ':'
            ),
            if (isAvailableForOtherStudents) TextSpan(
              text: fourthPart + ' ',
              style: const TextStyle(
                fontStyle: FontStyle.italic
              )
            ),
            if (isAvailableForOtherStudents) TextSpan(
              text: 'common.your_profile'.tr(),
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontStyle: FontStyle.italic
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                Navigator.push(context, MaterialPageRoute<ProfileView>(builder: (_) => ProfileView()));
              } 
            ),
            if (isAvailableForOtherStudents) TextSpan(
              text: '):',
              style: const TextStyle(
                fontStyle: FontStyle.italic
              )
            )
          ]
        )
      ),
    );
  }  

  Widget _showStudents() {
    List<User>? students = _lessonRequestProvider?.nextLesson?.students;
    Map<String, List<LessonNote>> studentsLessonsNotes = _lessonRequestProvider?.studentsLessonsNotes as Map<String, List<LessonNote>>;
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
          String studentId = students?[index].id as String;
          List<LessonNote> lessonsNotes = studentsLessonsNotes[studentId] != null ? studentsLessonsNotes[studentId] as List<LessonNote> : [];
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
                        ),
                        if (lessonsNotes.length > 0) TextSpan(
                          text: ' ('
                        ),
                        if (lessonsNotes.length > 0) TextSpan(
                          text: 'lesson_request.notes_previous_mentors'.tr(),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            showDialog(
                              context: context,
                              builder: (_) => AnimatedDialog(
                                widgetInside: LessonsNotesDialog(student: students?[index], lessonsNotes: lessonsNotes)
                              ),
                            );
                          } 
                        ),
                        if (lessonsNotes.length > 0) TextSpan(
                          text: ')'
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            'lesson_request.lesson_link'.tr(),
            style: const TextStyle(
              fontSize: 13.0,
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
                    _url,                   
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
            widgetInside: ChangeUrlDialog(url: _url)
          )
        );
      }                 
    );
  }

  Future<void> _launchMeetingUrl() async {
    if (await canLaunchUrl(Uri.parse(_url))) {
      await launchUrl(
        Uri.parse(_url),
        mode: LaunchMode.externalApplication,
      );  
    } else {
      throw 'Could not launch $_url';
    }  
  }

  Widget _showGuide() {
    return Container(
      margin: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: AppColors.SILVER),
          bottom: BorderSide(width: 1.0, color: AppColors.SILVER),
        )
      ),
      child: Center(
        child: InkWell(
          child: Text(
            'lesson_request.see_lesson_guide_link'.tr(),
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              fontSize: 13.0
            )
          ),
          onTap: () => {
            showDialog(
              context: context,
              builder: (_) => AnimatedDialog(
                widgetInside: LessonGuideDialog()
              )
            )
          }
        )
      )
    );
  }

  Widget _showButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 30.0,
              margin: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 1.0,
                  backgroundColor: AppColors.ALLPORTS,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
                ), 
                onPressed: () {
                  _showAddLessonsDialog();
                },
                child: Text(
                  'lesson_request.add_more_lessons'.tr(),
                  style: const TextStyle(color: Colors.white)
                )
              ),
            ),
            Container(
              height: 30.0,
              margin: const EdgeInsets.only(bottom: 5.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 1.0,
                  backgroundColor: AppColors.MONZA,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
                ), 
                child: Text('lesson_request.cancel_lesson'.tr(), style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  _showCancelLessonDialog();
                }
              )
            )
          ]
        ),
      ),
    );
  }

  void _showAddLessonsDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: AddLessonsDialog(lesson: _lessonRequestProvider?.nextLesson)
      ),
    );    
  }  

  void _showCancelLessonDialog() {
    Widget cancelLessonWidget;
    Lesson? nextLesson = _lessonRequestProvider?.nextLesson;
    bool isNextLessonRecurrent = Utils.isLessonRecurrent(nextLesson?.dateTime as DateTime, nextLesson?.endRecurrenceDateTime);
    if (isNextLessonRecurrent == true) {
      cancelLessonWidget = CancelNextLessonOptionsDialog(context: context);
    } else {
      cancelLessonWidget = CancelNextLessonDialog();
    }
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: cancelLessonWidget
      ),
    );    
  }

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showNextLessonCard();
  }
}