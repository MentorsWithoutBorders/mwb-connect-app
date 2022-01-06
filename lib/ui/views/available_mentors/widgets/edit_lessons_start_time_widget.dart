import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class EditLessonsStartTime extends StatefulWidget {
  const EditLessonsStartTime({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _EditLessonsStartTimeState();
}

class _EditLessonsStartTimeState extends State<EditLessonsStartTime> {
  AvailableMentorsViewModel? _availableMentorsProvider;
  Availability? _availability;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {  
      _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);
      _initAvalability();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  void _initAvalability() {
    _availability = _availableMentorsProvider?.getSelectedAvailability();
  }
  
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
    String dayOfWeek = _availability?.dayOfWeek as String;
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
            value: _availability?.time?.from
          ),
        )
      ]
    );
  }

  void _setTimeFrom(String? time) {
    setState(() {
      _availability?.time?.from = time;
    });
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
          onPressed: () {
            _sendLessonRequest();
          },
          child: Text(
            'available_mentors.send_request'.tr(),
            style: const TextStyle(
              color: Colors.white
            )
          )
        )
      ]
    ); 
  }

  void _sendLessonRequest() {

  }

  @override
  Widget build(BuildContext context) {
    return _showEditLessonsStartTimeDialog();
  }
}