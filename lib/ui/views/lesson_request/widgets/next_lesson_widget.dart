import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/cancel_next_lesson_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/change_url_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/bullet_point_widget.dart';

class NextLesson extends StatefulWidget {
  const NextLesson({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _NextLessonState();
}

class _NextLessonState extends State<NextLesson> {
  LessonRequestViewModel _lessonRequestProvider;
  String _url = '';

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
              _showButtons()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    Lesson nextLesson = _lessonRequestProvider.nextLesson;
    DateTime nextLessonDateTime = nextLesson.dateTime.toLocal();
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
      padding: const EdgeInsets.only(bottom: 20.0),
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
    return Padding(
      padding: const EdgeInsets.only(left: 3.0, right: 20.0, bottom: 15.0),
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
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
                        height: 1.2
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${students[index].name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                         TextSpan(
                          text: ' - ${students[index].organization.name}'
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
            'The link for the lesson is:',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.DOVE_GRAY
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
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

  Widget _showButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(bottom: 5.0, right: 15.0),
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
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: CancelNextLessonDialog(),
                    hasInput: true,
                  ),
                );
              }
            ),
          ),
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
              child: Text('lesson_request.change_url'.tr(), style: const TextStyle(color: Colors.white)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AnimatedDialog(
                    widgetInside: ChangeUrlDialog(url: _url),
                    hasInput: true,
                  ),
                );
              }
            ),
          ),
        ]
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showNextLessonCard();
  }
}