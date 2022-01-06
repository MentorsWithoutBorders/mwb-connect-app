import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/availabilities_list_widget.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/subfields_list_widget.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/edit_lessons_start_time_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';
import 'package:provider/provider.dart';

class AvailableMentor extends StatefulWidget {
  const AvailableMentor({Key? key, @required this.mentor})
    : super(key: key); 

  final User? mentor;

  @override
  State<StatefulWidget> createState() => _AvailableMentorState();
}

class _AvailableMentorState extends State<AvailableMentor> {
  AvailableMentorsViewModel? _availableMentorsProvider;  

  Widget _showAvailableMentor() {
    String errorMessage = _availableMentorsProvider!.errorMessage;
    String? selectedMentorId = _availableMentorsProvider?.selectedMentorId;
    bool shouldShowError = selectedMentorId != null && selectedMentorId == widget.mentor?.id && errorMessage !='';
    return AppCard(
      child: Wrap(
        children: [
          _showMentorName(),
          _showMentorFieldName(),
          SubfieldsList(mentorId: widget.mentor?.id, subfields: widget.mentor?.field?.subfields),
          AvailabilitiesList(mentorId: widget.mentor?.id, availabilities: widget.mentor?.availabilities),
          if (shouldShowError) _showError(),
          _showSendRequestButton()
        ],
      )
    );
  }

  Widget _showMentorName() {
    return Container(
      padding: const EdgeInsets.only(bottom: 5.0),
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

  Widget _showMentorFieldName() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      width: double.infinity,
      child: Text(
        widget.mentor?.field?.name as String,
        style: const TextStyle(
          color: AppColors.DOVE_GRAY
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
            _sendLessonRequest();
          }
        )
      )
    );
  }

  void _sendLessonRequest() {
    _availableMentorsProvider?.setSelectedMentorId(widget.mentor?.id);
    _availableMentorsProvider?.setErrorMessage('');
    if (_availableMentorsProvider!.isLessonRequestValid(widget.mentor as User)) {
      _showEditAvailabilityDialog();
    }
  }

  void _showEditAvailabilityDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: EditLessonsStartTime()
      )
    );     
  }  

  Widget _showError() {
    String _errorMessage = _availableMentorsProvider!.errorMessage;
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
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);    
    
    return _showAvailableMentor();
  }
}