import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests/widgets/availabilities_list_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests/widgets/subfields_list_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests/widgets/edit_course_details_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';


class MentorWaitingRequestItem extends StatefulWidget {
  const MentorWaitingRequestItem({Key? key, @required this.partnerMentor, @required this.selectedPartnerMentor, @required this.courseTypeText, @required this.subfieldOptionId, @required this.availabilityOptionId, @required this.courseDayOfWeek, @required this.courseHoursList, @required this.mentorSubfields, @required this.getSubfieldItemId, @required this.getAvailabilityItemId, @required this.onSelectSubfield, @required this.onSelectAvailability, @required this.onSelectMentor, @required this.onSendRequest, @required this.onGoBack, @required this.getErrorMessage})
    : super(key: key); 

  final CourseMentor? partnerMentor;
  final CourseMentor? selectedPartnerMentor;
  final String? courseTypeText;
  final String? subfieldOptionId;
  final String? availabilityOptionId;
  final String? courseDayOfWeek;
  final List<String>? courseHoursList;
  final List<Subfield>? mentorSubfields;
  final Function(String, int)? getSubfieldItemId;
  final Function(String, int)? getAvailabilityItemId;
  final Function(String?)? onSelectSubfield;
  final Function(String?)? onSelectAvailability;
  final Function(CourseMentor)? onSelectMentor;
  final Function(String, String)? onSendRequest;
  final Function? onGoBack;
  final Function(CourseMentor)? getErrorMessage;

  @override
  State<StatefulWidget> createState() => _MentorsWaitingRequeststate();
}

class _MentorsWaitingRequeststate extends State<MentorWaitingRequestItem> {
  Widget _showMentorWaitingRequestItem() {
    String errorMessage = widget.getErrorMessage!(widget.partnerMentor as CourseMentor);
    return AppCard(
      child: Wrap(
        children: [
          _showPartnerMentorName(),
          _showCourseType(),
          SubfieldsList(
            mentor: widget.partnerMentor,
            optionId: widget.subfieldOptionId,
            getId: widget.getSubfieldItemId,
            onSelect: widget.onSelectSubfield
          ),
          AvailabilitiesList(
            mentor: widget.partnerMentor,
            optionId: widget.availabilityOptionId,
            getId: widget.getAvailabilityItemId,
            onSelect: widget.onSelectAvailability
          ),
          if (errorMessage.isNotEmpty) _showError(),
          _showSendRequestButton()
        ],
      )
    );
  }

  Widget _showPartnerMentorName() {
    String partnerMentorName = widget.partnerMentor?.name as String;
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      width: double.infinity,
      child: Text(
        partnerMentorName,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showCourseType() {
    String courseTypeText = widget.courseTypeText as String;
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      width: double.infinity,
      child: Text(
        courseTypeText,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY,
          fontStyle: FontStyle.italic
        )
      )
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
            backgroundColor: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 3.0, 25.0, 3.0),
          ), 
          child: Text('common.send_request'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () async {
            _setSelectedMentor();
            await Future<void>.delayed(const Duration(milliseconds: 100));
            String errorMessage = widget.getErrorMessage!(widget.partnerMentor as CourseMentor);
            if (errorMessage.isEmpty) {
              _showEditCourseDetailsDialog();
            }
          }
        )
      )
    );
  }

  void _showEditCourseDetailsDialog() {
    Subfield partnerMentorSubfield = widget.selectedPartnerMentor?.field?.subfields![0] ?? Subfield();
    String courseDayOfWeek = widget.courseDayOfWeek as String;
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: EditCourseDetailsDialog(
          partnerMentorSubfield: partnerMentorSubfield,
          dayOfWeek: courseDayOfWeek,
          hoursList: widget.courseHoursList,
          mentorSubfields: widget.mentorSubfields,
          onSendRequest: _sendMentorPartnershipRequest
        )
      )
    ).then((shouldGoBack) {
      if (shouldGoBack == true) {
        widget.onGoBack!();
      }
    });
  }

  void _setSelectedMentor()  {
    widget.onSelectMentor!(widget.partnerMentor as CourseMentor);
  }

  Future<void> _sendMentorPartnershipRequest(String mentorSubfieldId, String courseStartTime) async {
    await widget.onSendRequest!(mentorSubfieldId, courseStartTime);
  }

  Widget _showError() {
    String errorMessage = widget.getErrorMessage!(widget.partnerMentor as CourseMentor);
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