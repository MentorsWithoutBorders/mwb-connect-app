import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/availabilities_list_widget.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/subfields_list_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';

class AvailableMentor extends StatefulWidget {
  const AvailableMentor({Key? key, @required this.mentor})
    : super(key: key); 

  final User? mentor;

  @override
  State<StatefulWidget> createState() => _AvailableMentorState();
}

class _AvailableMentorState extends State<AvailableMentor> {
  Widget _showAvailableMentor() {
    return AppCard(
      child: Wrap(
        children: [
          _showMentorName(),
          _showMentorFieldName(),
          SubfieldsList(mentorId: widget.mentor?.id, subfields: widget.mentor?.field?.subfields),
          AvailabilitiesList(mentorId: widget.mentor?.id, availabilities: widget.mentor?.availabilities)
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

  @override
  Widget build(BuildContext context) {
    return _showAvailableMentor();
  }
}