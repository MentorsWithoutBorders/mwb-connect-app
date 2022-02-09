import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/lesson_request_result_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/available_mentors_view.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class FindAvailableMentorOptionsDialog extends StatefulWidget {
  const FindAvailableMentorOptionsDialog({Key? key, @required this.mentor, this.shouldReloadCallback, @required this.context})
    : super(key: key);  

  final User? mentor;
  final VoidCallback? shouldReloadCallback; 
  final BuildContext? context;

  @override
  State<StatefulWidget> createState() => _FindAvailableMentorOptionsDialogState();
}

class _FindAvailableMentorOptionsDialogState extends State<FindAvailableMentorOptionsDialog> {
  AvailableMentorsViewModel? _availableMentorsProvider;
  ConnectWithMentorViewModel? _connectWithMentorProvider;
  bool _isSendingLessonRequest = false;    

  Widget _showFindAvailableMentorOptionsDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
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
    String title = 'connect_with_mentor.find_available_mentor'.tr();
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        ),
      )
    );
  }

  Widget _showOptions() {
    return Wrap(
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3.0),
            child: Text(
              'connect_with_mentor.send_request_previous_mentor_text'.tr(args: [widget.mentor?.name as String]),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.DOVE_GRAY
              )
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 15.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.ALLPORTS,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              )
            ),             
            onPressed: () async {
              await _sendLessonRequest();
            },
            child: !_isSendingLessonRequest ? Text(
              'connect_with_mentor.send_request_previous_mentor'.tr(),
              style: const TextStyle(color: Colors.white)
            ) : SizedBox(
              width: 56.0,
              height: 16.0,
              child: ButtonLoader()
            )
          )
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Text(
              'connect_with_mentor.find_new_mentor_text'.tr(),
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.DOVE_GRAY
              )
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.ALLPORTS,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              )
            ),
            onPressed: () async {
              await _goToAvailableMentors();
              Navigator.pop(context);
            },
            child: Text('connect_with_mentor.find_new_mentor'.tr(), style: const TextStyle(color: Colors.white))
          )
        ),
        Center(
          child: SizedBox(
            height: 30.0,
            child: TextButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: AppColors.BERMUDA_GRAY)
                )
              ),       
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'common.close'.tr(),
                style: const TextStyle(color: AppColors.BERMUDA_GRAY)
              )
            ),
          )
        )
      ]
    );
  }

  Future<void> _sendLessonRequest() async {
    Lesson? previousLesson = _connectWithMentorProvider?.previousLesson;
    Subfield? subfield = previousLesson?.subfield;
    DateTime lessonDateTime = previousLesson?.dateTime as DateTime;
    Availability? availability = Availability(
      dayOfWeek: DateFormat(AppConstants.dayOfWeekFormat).format(lessonDateTime),
      time: Time(
        from: DateFormat(AppConstants.timeFormat).format(lessonDateTime),
        to: DateFormat(AppConstants.timeFormat).format(lessonDateTime)
      )
    );
    setState(() {
      _isSendingLessonRequest = true;
    });
    _availableMentorsProvider?.setSelectedMentor(mentor: null);    
    _availableMentorsProvider?.setSelectedMentor(mentor: widget.mentor, subfield: subfield, availability: availability);    
    _availableMentorsProvider?.setSelectedMentor(mentor: widget.mentor);    
    LessonRequestResult lessonRequestResult = await _availableMentorsProvider?.sendCustomLessonRequest() as LessonRequestResult;
    await _resetValues(context);
    _availableMentorsProvider?.mergeAvailabilities();
    if (lessonRequestResult.id != null) {
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context, false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AnimatedDialog(
            widgetInside: NotificationDialog(
              text: 'connect_with_mentor.previous_mentor_unavailable'.tr(), 
              buttonText: 'common.ok'.tr(),
              shouldReload: true
            )
          );
        }
      );      
    }
  }  
  
  Future<void> _goToAvailableMentors() async {
    final shouldReload = await Navigator.push(context, MaterialPageRoute(builder: (_) => AvailableMentorsView()));  
    if (shouldReload == true) {
      widget.shouldReloadCallback!();
    }
  }

  Future<bool> _resetValues(BuildContext context) async {
    _availableMentorsProvider?.resetValues();
    return true;
  }    

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showFindAvailableMentorOptionsDialog();
  }
}

