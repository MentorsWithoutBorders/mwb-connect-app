import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/lesson_recurrence_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/cancel_next_lesson_options_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/cancel_next_lesson_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/lesson_guide_dialog.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/lessons_notes_dialog.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/bullet_point_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class NextLesson extends StatefulWidget {
  const NextLesson({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _NextLessonState();
}

class _NextLessonState extends State<NextLesson> {
  LessonRequestViewModel _lessonRequestProvider;
  String _url = '';
  bool _isUpdatingRecurrence = false;

  Widget _showNextLessonCard() {
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
              if (_lessonRequestProvider.isNextLesson) LessonRecurrence(),
              _showButtons()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    if (!_lessonRequestProvider.isNextLesson) {
      return SizedBox.shrink();
    }
    Lesson nextLesson = _lessonRequestProvider.nextLesson;
    DateTime nextLessonDateTime = nextLesson.dateTime;
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson);
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson);
    DateTime now = DateTime.now();
    String subfield = nextLesson.subfield.name.toLowerCase();
    String date = dateFormat.format(nextLessonDateTime);
    String time = timeFormat.format(nextLessonDateTime);
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String studentPlural = plural('student', nextLesson.students.length);
    String text = 'lesson_request.lesson_scheduled'.tr(args: [subfield, date, time, timeZone, studentPlural]);
    String firstPart = text.substring(0, text.indexOf(subfield));
    String secondPart = text.substring(text.indexOf(subfield) + subfield.length, text.indexOf(date));
    String thirdPart = text.substring(text.indexOf(timeZone) + timeZone.length, text.indexOf('('));
    String fourthPart = text.substring(text.indexOf('('));
    _url = nextLesson.meetingUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.DOVE_GRAY,
            height: 1.5
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
            TextSpan(
              text: fourthPart,
              style: const TextStyle(
                fontStyle: FontStyle.italic
              )
            ),
            TextSpan(
              text: ' ' + 'common.your_profile'.tr(),
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontStyle: FontStyle.italic
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                Navigator.push(context, MaterialPageRoute<ProfileView>(builder: (_) => ProfileView()));
              } 
            ),
            TextSpan(
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
    List<User> students = _lessonRequestProvider.nextLesson.students;
    return Container(
      margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 10.0, 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.SILVER)
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: students.length,
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
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.DOVE_GRAY,
                        height: 1.4
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${students[index].name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        TextSpan(
                          text: ' - ${students[index].organization.name} ('
                        ),
                        TextSpan(
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
                                widgetInside: LessonsNotesDialog(student: students[index])
                              ),
                            );
                          } 
                        ),
                        TextSpan(
                          text: ')'
                        )
                      ],
                    )
                  )
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _showLink() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            'lesson_request.lesson_link'.tr(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.DOVE_GRAY
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Center(
            child: Text(
              _url,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
              )
            ),
          ),
        ),
      ],
    );
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
              ),
            )
          }
        ),
      ),
    );
  }

  Widget _showButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 30.0,
              margin: const EdgeInsets.only(bottom: 15.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 1.0,
                  primary: AppColors.ALLPORTS,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
                ), 
                onPressed: () async {
                  if (!_isUpdatingRecurrence) {
                    await _updateLessonRecurrence();
                  }
                },
                child: !_isUpdatingRecurrence ? Text(
                  'lesson_request.update_lesson_recurrence'.tr(),
                  style: const TextStyle(color: Colors.white)
                ) : SizedBox(
                  width: 161.0,
                  height: 16.0,
                  child: ButtonLoader(),
                )
              ),
            ),
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
                child: Text('lesson_request.cancel_next_lesson'.tr(), style: const TextStyle(color: Colors.white)),
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

  void _showCancelLessonDialog() {
    Widget cancelLessonWidget;
    if (_lessonRequestProvider.nextLesson.isRecurrent) {
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
  
  Future<void> _updateLessonRecurrence() async {
    _setIsUpdatingRecurrence(true);   
    await _lessonRequestProvider.updateLessonRecurrence();
    _showToast();
    _setIsUpdatingRecurrence(false);
  }

  void _setIsUpdatingRecurrence(bool isUpdating) {
    setState(() {
      _isUpdatingRecurrence = isUpdating;
    });      
  }

  void _showToast() {
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('lesson_request.lesson_recurrence_updated'.tr()),
        action: SnackBarAction(
          label: 'common.close'.tr(), onPressed: scaffold.hideCurrentSnackBar
        ),
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showNextLessonCard();
  }
}