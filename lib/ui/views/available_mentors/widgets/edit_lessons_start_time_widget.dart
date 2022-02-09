import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/lesson_request_result_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/notification_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class EditLessonsStartTime extends StatefulWidget {
  const EditLessonsStartTime({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _EditLessonsStartTimeState();
}

class _EditLessonsStartTimeState extends State<EditLessonsStartTime> {
  AvailableMentorsViewModel? _availableMentorsProvider;
  bool _isSendingLessonRequest = false;  
  
  Widget _showEditLessonsStartTimeDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showTimeFromDropdown(),
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
          'available_mentors.lessons_start_time'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        ),
      )
    );
  }

  Widget _showTimeFromDropdown() {
    Availability? availability = _availableMentorsProvider?.selectedMentor?.availabilities![0];
    String selectedLessonStartTime = _availableMentorsProvider?.selectedLessonStartTime as String;
    String dayOfWeek = availability?.dayOfWeek as String;
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0, right: 3.0),
          child: Text(
            'available_mentors.preferred_start_time'.tr(args: [dayOfWeek]),
            style: const TextStyle(
              fontSize: 13.0,
              color: AppColors.DOVE_GRAY
            )
          )
        ),
        Container(
          width: 80.0,
          height: 30.0,
          margin: const EdgeInsets.only(bottom: 15.0),
          child: Dropdown(
            dropdownMenuItemList: _buildTimeDropdown(),
            onChanged: _setTimeFrom,
            value: selectedLessonStartTime
          ),
        )
      ]
    );
  }

  void _setTimeFrom(String? timeFrom) {
    _availableMentorsProvider?.setSelectedLessonStartTime(timeFrom as String);
  }    

  List<DropdownMenuItem<String>> _buildTimeDropdown() {
    final List<String> times = _availableMentorsProvider!.buildHoursList();
    final List<DropdownMenuItem<String>> items = [];
    for (final String time in times) {
      items.add(DropdownMenuItem(
        value: time,
        child: Text(time),
      ));
    }
    return items;
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
            Navigator.pop(context, false);
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 12.0)
          ), 
          onPressed: () async {
            await _sendLessonRequest();
          },
          child: !_isSendingLessonRequest ? Text(
            'available_mentors.send_request'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 56.0,
            height: 16.0,
            child: ButtonLoader()
          )
        )
      ]
    ); 
  }

  Future<void> _sendLessonRequest() async {
    setState(() {
      _isSendingLessonRequest = true;
    });
    User? mentor = _availableMentorsProvider?.selectedMentor;
    _availableMentorsProvider?.setSelectedMentor(mentor: mentor);    
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
              text: 'connect_with_mentor.selected_mentor_unavailable'.tr(), 
              buttonText: 'common.ok'.tr(),
              shouldReload: true
            )
          );
        }
      );      
    }
  }

  Future<void> _resetValues(BuildContext context) async {
    _availableMentorsProvider?.resetValues();
  }     

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return _showEditLessonsStartTimeDialog();
  }
}