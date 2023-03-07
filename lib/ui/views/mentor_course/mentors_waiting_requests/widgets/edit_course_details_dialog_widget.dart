import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';
import 'package:mwb_connect_app/ui/widgets/subfield_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class EditCourseDetailsDialog extends StatefulWidget {
  const EditCourseDetailsDialog({Key? key, this.partnerMentorSubfield, this.dayOfWeek, this.hoursList, this.mentorSubfields, this.onSendRequest})
    : super(key: key);

  final Subfield? partnerMentorSubfield;
  final String? dayOfWeek;
  final List<String>? hoursList;
  final List<Subfield>? mentorSubfields;
  final Function(String, String)? onSendRequest;

  @override
  State<StatefulWidget> createState() => _EditCourseDetailsDialogState();
}

class _EditCourseDetailsDialogState extends State<EditCourseDetailsDialog> {
  bool _isSendingMentorPartnershipRequest = false;
  String? _subfieldId;  
  String? _startTime;
  
  @override
  void initState() {
    super.initState();
    _subfieldId = widget.mentorSubfields!.firstWhere((Subfield subfield) => subfield.id == widget.partnerMentorSubfield?.id, orElse: () => widget.mentorSubfields![0]).id;
    _startTime = widget.hoursList![0];
  }
  
  Widget _showEditstartTimeDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          if (widget.mentorSubfields!.length > 1) _showPartnerMentorSubfieldLabel(),
          if (widget.mentorSubfields!.length > 1) _showPartnerMentorSubfield(),
          if (widget.mentorSubfields!.length > 1) _showMentorSubfieldsLabel(),
          if (widget.mentorSubfields!.length > 1) _showMentorSubfieldsDropdown(),
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
          'mentor_course.set_course_details'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        ),
      )
    );
  }

  Widget _showPartnerMentorSubfieldLabel() {
    String label = 'mentor_course.mentor_partnership_request_partner_subfield'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 5.0),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showPartnerMentorSubfield() {
    String subfieldName = widget.partnerMentorSubfield?.name as String;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(subfieldName),
    );
  }  

  Widget _showMentorSubfieldsLabel() {
    String label = 'mentor_course.mentor_partnership_request_own_subfield'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 5.0),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showMentorSubfieldsDropdown() {
    return SubfieldDropdown(
      subfields: widget.mentorSubfields,
      selectedSubfieldId: _subfieldId,
      onSelect: (String? subfieldId) {
        _setSubfieldId(subfieldId);
      }
    );
  }

  void _setSubfieldId(String? value) {
    setState(() {
      _subfieldId = value;
    });
  }  

  Widget _showTimeFromDropdown() {
    String dayOfWeek = widget.dayOfWeek as String;
    String preferredStartTime = 'mentor_course.mentor_partnership_request_start_time'.tr(args: [dayOfWeek]);
    return Wrap(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 3.0, bottom: 7.0),
          child: Text(
            preferredStartTime,
            style: const TextStyle(
              color: AppColors.TANGO,
              fontWeight: FontWeight.bold
            )
          )
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
                  onChanged: _setStartTime,
                  value: _startTime
                )
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text(
                    'mentor_course.available_partners_lesson_duration'.tr(),
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

  void _setStartTime(String? value) {
    setState(() {
      _startTime = value;
    });
  }

  List<DropdownMenuItem<String>> _buildTimeDropdown() {
    final List<String> times = widget.hoursList as List<String>;
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
            'common.send_request'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 83.0,
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
    await widget.onSendRequest!(_subfieldId as String, _startTime as String);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return _showEditstartTimeDialog();
  }
}