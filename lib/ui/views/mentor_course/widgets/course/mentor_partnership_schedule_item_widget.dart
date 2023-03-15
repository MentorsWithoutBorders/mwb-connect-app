import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_schedule_item_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class MentorPartnershipScheduleItem extends StatefulWidget {
  const MentorPartnershipScheduleItem({Key? key, @required this.scheduleItem, @required this.mentors, @required this.onUpdate})
    : super(key: key); 

  final MentorPartnershipScheduleItemModel? scheduleItem;
  final List<CourseMentor>? mentors;
  final Function(String?, String?)? onUpdate;

  @override
  State<StatefulWidget> createState() => _MentorPartnershipScheduleItemState();
}

class _MentorPartnershipScheduleItemState extends State<MentorPartnershipScheduleItem> {
  String? _selectedMentorId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) async {
    final String? selectedMentorId = widget.scheduleItem?.mentor?.id;
    _setSelectedMentor(selectedMentorId);
  }    

  Widget _showMentorPartnershipScheduleItem() {
    DateFormat monthDayFormat = DateFormat(AppConstants.monthDayFormat, 'en'); 
    String lessonDate = monthDayFormat.format(widget.scheduleItem?.lessonDateTime as DateTime);
    return Container(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60.0,
            child: Text(
              lessonDate,
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.TANGO,
                fontWeight: FontWeight.bold
              )
            ),
          ),
          Expanded(
            child: Container(
              height: 35.0,
              child: Dropdown<String>(
                dropdownMenuItemList: _buildMentorsList(),
                onChanged: _setSelectedMentor,
                value: _selectedMentorId
              )
            )
          )
        ]
      )
    );
  }

  List<DropdownMenuItem<String>> _buildMentorsList() {
    final List<DropdownMenuItem<String>> items = [];
    List<CourseMentor>? mentors = widget.mentors;
    if (mentors != null) {
      for (final CourseMentor mentor in mentors) {
        items.add(DropdownMenuItem<String>(
          value: mentor.id,
          child: Text(mentor.name as String),
        ));
      }
    }
    return items;
  }  

  void _setSelectedMentor(String? mentorId) {
    setState(() {
      _selectedMentorId = mentorId;
    });
    final String? id = widget.scheduleItem?.id;
    widget.onUpdate!(id, mentorId);
  }

  @override
  Widget build(BuildContext context) {
    return _showMentorPartnershipScheduleItem();
  }
}