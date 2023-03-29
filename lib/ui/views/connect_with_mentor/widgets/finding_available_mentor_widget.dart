import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/cancel_lesson_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class FindingAvailableMentor extends StatefulWidget {
  const FindingAvailableMentor({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _FindingAvailableMentorState();
}

class _FindingAvailableMentorState extends State<FindingAvailableMentor> {
  ConnectWithMentorViewModel? _connectWithMentorProvider;  

  Widget _showFindingAvailableMentorCard() {
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
    LessonRequestModel? lessonRequest = _connectWithMentorProvider?.lessonRequest;
    DateTime lessonRequestDateTime = lessonRequest?.lessonDateTime as DateTime;   
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');
    DateTime now = DateTime.now();
    String subfield = lessonRequest?.subfield?.name?.toLowerCase() as String;
    String article = Utils.getIndefiniteArticle(subfield);
    String mentorName = lessonRequest?.mentor?.name as String;
    String date = dateFormat.format(lessonRequestDateTime);
    String time = timeFormat.format(lessonRequestDateTime);
    String timeZone = now.timeZoneName;
    String lesson = plural('lesson', 1);
    String at = 'common.at'.tr();

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 12.0),
          child: RichText(
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12.0,
                color: AppColors.DOVE_GRAY,
                height: 1.4
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'connect_with_mentor.requested_lesson'.tr()
                ),
                TextSpan(
                  text: ' ' + article + ' ' + subfield + ' ' + lesson
                ),
                TextSpan(
                  text: ' ' + 'common.with'.tr() + ' '
                ),
                TextSpan(
                  text: mentorName,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: ' ' + 'common.on'.tr() + ' '
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
                  text: '.'
                )
              ],
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 7.0),
          child: Text(
            'connect_with_mentor.waiting_mentor'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.DOVE_GRAY,
              height: 1.4
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Center(
            child: Text(
              'common.waiting_time'.tr(),
              style: const TextStyle(
                fontSize: 12.0,
                fontStyle: FontStyle.italic,
                color: AppColors.DOVE_GRAY,
                height: 1.4
              )
            )
          ),
        )
      ]
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
            backgroundColor: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ), 
          child: Text('common.cancel_request'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AnimatedDialog(
                widgetInside: CancelLessonRequestDialog()
              )
            ); 
          }
        ),
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showFindingAvailableMentorCard();
  }
}