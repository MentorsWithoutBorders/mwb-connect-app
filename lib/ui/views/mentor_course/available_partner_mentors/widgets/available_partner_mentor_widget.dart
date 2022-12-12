import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_partner_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/available_partner_mentors/widgets/availabilities_list_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/available_partner_mentors/widgets/subfields_list_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/available_partner_mentors/widgets/edit_course_start_time_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';


class AvailablePartnerMentor extends StatefulWidget {
  const AvailablePartnerMentor({Key? key, @required this.partnerMentor})
    : super(key: key); 

  final User? partnerMentor;

  @override
  State<StatefulWidget> createState() => _AvailablePartnerMentorState();
}

class _AvailablePartnerMentorState extends State<AvailablePartnerMentor> {
  AvailablePartnerMentorsViewModel? _availablePartnerMentorsProvider;  

  Widget _showAvailablePartnerMentor() {
    String errorMessage = _availablePartnerMentorsProvider!.errorMessage;
    String? selectedPartnerMentorId = _availablePartnerMentorsProvider?.selectedPartnerMentor?.id;
    bool shouldShowError = selectedPartnerMentorId != null && selectedPartnerMentorId == widget.partnerMentor?.id && errorMessage !='';
    return AppCard(
      child: Wrap(
        children: [
          _showPartnerMentorName(),
          _showPartnerMentorFieldName(),
          SubfieldsList(mentor: widget.partnerMentor),
          AvailabilitiesList(mentor: widget.partnerMentor),
          if (shouldShowError) _showError(),
          _showSendRequestButton()
        ],
      )
    );
  }

  Widget _showPartnerMentorName() {
    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
      width: double.infinity,
      child: Text(
        widget.partnerMentor?.name as String,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showPartnerMentorFieldName() {
    String fieldName = widget.partnerMentor?.field?.name as String;
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      width: double.infinity,
      child: Text(
        fieldName,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY,
          height: 1.4
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
            primary: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 3.0, 25.0, 3.0),
          ), 
          child: Text('available_mentors.send_request'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            _editAvailability();
          }
        )
      )
    );
  }

  void _editAvailability() {
    _availablePartnerMentorsProvider?.setErrorMessage('');
    _availablePartnerMentorsProvider?.setSelectedPartnerMentor(partnerMentor: null);
    _availablePartnerMentorsProvider?.setMentorPartnershipRequestButtonId(widget.partnerMentor?.id);
    _availablePartnerMentorsProvider?.setDefaultSubfield(widget.partnerMentor as User);
    _availablePartnerMentorsProvider?.setDefaultAvailability(widget.partnerMentor as User);
    _availablePartnerMentorsProvider?.setSelectedPartnerMentor(partnerMentor: widget.partnerMentor);
    if (_availablePartnerMentorsProvider!.isMentorPartnershipRequestValid(widget.partnerMentor as User)) {
      _showEditAvailabilityDialog();
    }
  }

  void _showEditAvailabilityDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: EditCourseStartTime()
      )
    ).then((shouldGoBack) {
      if (shouldGoBack == true) {
        Navigator.pop(context, true);
      }
    });
  } 

  Widget _showError() {
    String _errorMessage = _availablePartnerMentorsProvider!.errorMessage;
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      width: double.infinity,
      child: Center(
        child: Text(
          _errorMessage,
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
    _availablePartnerMentorsProvider = Provider.of<AvailablePartnerMentorsViewModel>(context);    
    
    return _showAvailablePartnerMentor();
  }
}