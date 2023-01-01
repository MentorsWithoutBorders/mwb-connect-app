import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests/widgets/availabilities_list_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests/widgets/subfields_list_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests/widgets/edit_course_start_time_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';


class MentorWaitingRequestItem extends StatefulWidget {
  const MentorWaitingRequestItem({Key? key, @required this.mentor, @required this.subfieldOptionId, @required this.availabilityOptionId, @required this.courseStartTime, @required this.courseHoursList, @required this.errorMessage, @required this.shouldShowError, @required this.getSubfieldItemId, @required this.getAvailabilityItemId, @required this.onSelectSubfield, @required this.onSelectAvailability, @required this.onSelectCourseStartTime, @required this.onSelectMentor, @required this.onSendRequest})
    : super(key: key); 

  final CourseMentor? mentor;
  final String? subfieldOptionId;
  final String? availabilityOptionId;
  final String? courseStartTime;
  final List<String>? courseHoursList;
  final String? errorMessage;
  final bool? shouldShowError;
  final Function(String, int)? getSubfieldItemId;
  final Function(String, int)? getAvailabilityItemId;
  final Function(String?)? onSelectSubfield;
  final Function(String?)? onSelectAvailability;
  final Function(String?)? onSelectCourseStartTime;
  final Function(CourseMentor)? onSelectMentor;
  final Function(CourseMentor)? onSendRequest;

  @override
  State<StatefulWidget> createState() => _MentorsWaitingRequeststate();
}

class _MentorsWaitingRequeststate extends State<MentorWaitingRequestItem> {
  Widget _showMentorWaitingRequestItem() {
    bool shouldShowError = widget.shouldShowError as bool;
    return AppCard(
      child: Wrap(
        children: [
          _showPartnerMentorName(),
          SubfieldsList(
            mentor: widget.mentor,
            optionId: widget.subfieldOptionId,
            getId: widget.getSubfieldItemId,
            onSelect: widget.onSelectSubfield
          ),
          AvailabilitiesList(
            mentor: widget.mentor,
            optionId: widget.availabilityOptionId,
            getId: widget.getAvailabilityItemId,
            onSelect: widget.onSelectAvailability
          ),
          if (shouldShowError) _showError(),
          _showSendRequestButton()
        ],
      )
    );
  }

  Widget _showPartnerMentorName() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      width: double.infinity,
      child: Text(
        widget.mentor?.name as String,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showSendRequestButton() {
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 3.0, 25.0, 3.0),
          ), 
          child: Text('available_mentors.send_request'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            if (widget.shouldShowError != true) {
              _showEditAvailabilityDialog();
            }
          }
        )
      )
    );
  }

  void _showEditAvailabilityDialog() {
    _selectMentor();
    String? courseDayOfWeek = widget.mentor?.availabilities![0].dayOfWeek;
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: EditCourseStartTime(
          dayOfWeek: courseDayOfWeek,
          startTime: widget.courseStartTime,
          hoursList: widget.courseHoursList,
          onSelect: widget.onSelectCourseStartTime,
          onSendRequest: _sendMentorPartnershipRequest
        )
      )
    ).then((shouldGoBack) {
      if (shouldGoBack == true) {
        Navigator.pop(context, true);
      }
    });
  }

  void _selectMentor() {
    widget.onSelectMentor!(widget.mentor as CourseMentor);
  }

  void _sendMentorPartnershipRequest() {
    widget.onSendRequest!(widget.mentor as CourseMentor);
  }

  Widget _showError() {
    String errorMessage = widget.errorMessage as String;
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      width: double.infinity,
      child: Center(
        child: Text(
          errorMessage,
          style: const TextStyle(
            fontSize: 12.0,
            color: AppColors.MONZA
          )
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showMentorWaitingRequestItem();
  }
}