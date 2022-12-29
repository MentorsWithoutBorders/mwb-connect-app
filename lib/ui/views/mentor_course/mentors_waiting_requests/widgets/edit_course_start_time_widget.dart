import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentors_waiting_requests_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class EditCourseStartTime extends StatefulWidget {
  const EditCourseStartTime({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _EditCourseStartTimeState();
}

class _EditCourseStartTimeState extends State<EditCourseStartTime> {
  MentorsWaitingRequestsViewModel? _mentorsWaitingRequestsProvider;
  bool _isSendingMentorPartnershipRequest = false;  
  
  Widget _showEditCourseStartTimeDialog() {
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
          'available_mentors.lesson_start_time'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        ),
      )
    );
  }

  Widget _showTimeFromDropdown() {
    Availability? availability = _mentorsWaitingRequestsProvider?.selectedPartnerMentor?.availabilities![0];
    String selectedCourseStartTime = _mentorsWaitingRequestsProvider?.selectedCourseStartTime as String;
    String dayOfWeek = availability?.dayOfWeek as String;
    String preferredStartTime = 'available_mentors.preferred_start_time'.tr(args: [dayOfWeek]);
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0, right: 3.0),
          child: HtmlWidget(preferredStartTime)
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80.0,
                height: 30.0,
                child: Dropdown(
                  dropdownMenuItemList: _buildTimeDropdown(),
                  onChanged: _setTimeFrom,
                  value: selectedCourseStartTime
                )
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text(
                    'available_mentors.lesson_duration'.tr(),
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                      color: AppColors.DOVE_GRAY
                    )
                  ),
                ),
              )
            ]
          ),
        )
      ]
    );
  }

  void _setTimeFrom(String? timeFrom) {
    _mentorsWaitingRequestsProvider?.setSelectedCourseStartTime(timeFrom as String);
  }    

  List<DropdownMenuItem<String>> _buildTimeDropdown() {
    final List<String> times = _mentorsWaitingRequestsProvider!.buildHoursList();
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
            await _sendMentorPartnershipRequest();
          },
          child: !_isSendingMentorPartnershipRequest ? Text(
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

  Future<void> _sendMentorPartnershipRequest() async {
    setState(() {
      _isSendingMentorPartnershipRequest = true;
    });
    User? partnerMentor = _mentorsWaitingRequestsProvider?.selectedPartnerMentor;
    _mentorsWaitingRequestsProvider?.setSelectedPartnerMentor(partnerMentor: partnerMentor);    
    await _mentorsWaitingRequestsProvider?.sendMentorPartnershipRequest();
    await _resetValues(context);
    _mentorsWaitingRequestsProvider?.mergeAvailabilities();
    Navigator.pop(context, true);
  }

  Future<void> _resetValues(BuildContext context) async {
    _mentorsWaitingRequestsProvider?.resetValues();
  }     

  @override
  Widget build(BuildContext context) {
    _mentorsWaitingRequestsProvider = Provider.of<MentorsWaitingRequestsViewModel>(context);

    return _showEditCourseStartTimeDialog();
  }
}