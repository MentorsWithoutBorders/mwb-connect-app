import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';
import 'package:mwb_connect_app/ui/widgets/subfield_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class EditCourseDetailsDialog extends StatefulWidget {
  const EditCourseDetailsDialog({Key? key, @required this.subfields, @required this.previousMeetingUrl, @required this.onSetCourseDetails})
    : super(key: key); 

  final List<Subfield>? subfields;
  final String? previousMeetingUrl;
  final Function(String, Availability?, String)? onSetCourseDetails;  

  @override
  State<StatefulWidget> createState() => _EditCourseDetailsDialogState();
}

class _EditCourseDetailsDialogState extends State<EditCourseDetailsDialog> {
  final String _defaultDayOfWeek = Utils.translateDayOfWeekToEng(Utils.daysOfWeek[5]);
  final String _defaultTimeFrom = '10am';
  final String urlType = AppConstants.meetingUrlType;    
  Availability? _availability;
  String? _subfieldId;
  String _meetingUrl = '';
  bool _shouldShowError = false;  
  bool _isInit = false;
  bool _isSchedulingCourse = false;

  @override
  void initState() {
    _meetingUrl = widget.previousMeetingUrl ?? '';
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {  
      _initAvalability();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  void _initAvalability() {
    _subfieldId = widget.subfields![0].id;
    _availability = Availability(dayOfWeek: _defaultDayOfWeek, time: Time(from: _defaultTimeFrom));
  }
  
  Widget _showEditCourseDetailsDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          if (widget.subfields!.length > 1) _showSubfieldsLabel(),
          if (widget.subfields!.length > 1) _showSubfieldsDropdown(),
          _showDayTimeLabel(),
          _showDayTimeDropdowns(),
          _showMeetingUrlLabel(),
          _showMeetingUrlInput(),
          _showStartCourseText(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          'mentor_course.set_course_details'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showSubfieldsLabel() {
    String title = 'common.choose_subfield'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 5.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showSubfieldsDropdown() {
    return Container(
      height: 47.0,
      child: SubfieldDropdown(
        subfields: widget.subfields,
        selectedSubfieldId: _subfieldId,
        onSelect: (String? subfieldId) {
          _setSubfieldId(subfieldId);
        }
      ),
    );
  }

  void _setSubfieldId(String? value) {
    setState(() {
      _subfieldId = value;
    });
  }
  
  Widget _showDayTimeLabel() {
    String title = 'mentor_course.choose_day_time_course'.tr();
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }  

  Widget _showDayTimeDropdowns() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _showDayOfWeekDropdown(),
          Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 5.0),
            child: Text('common.at'.tr().toLowerCase())
          ),
          _showTimeDropdown()
        ]
      ),
    );
  }

  Widget _showDayOfWeekDropdown() {
    return Expanded(
      child: Container(
        height: 37.0,
        child: Dropdown(
          dropdownMenuItemList: _buildDayOfWeekDropdown(),
          onChanged: _setDayOfWeek,
          value: _availability?.dayOfWeek
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDayOfWeekDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    for (final String dayOfWeek in Utils.daysOfWeek) {
      items.add(DropdownMenuItem(
        value: dayOfWeek,
        child: Text(dayOfWeek),
      ));
    }
    return items;
  }  

  void _setDayOfWeek(String? dayOfWeek) {
    setState(() {
      _availability?.dayOfWeek = dayOfWeek;
    });
  }  

  Widget _showTimeDropdown() {
    return Container(
      width: 90.0,
      height: 37.0,
      child: Dropdown(
        dropdownMenuItemList: _buildTimeDropdown(),
        onChanged: _setTimeFrom,
        value: _availability?.time?.from
      ),
    );
  }

  void _setTimeFrom(String? time) {
    setState(() {
      _availability?.time?.from = time;
    });
  }    

  List<DropdownMenuItem<String>> _buildTimeDropdown() {
    final List<String> times = Utils.buildHoursList();
    final List<DropdownMenuItem<String>> items = [];
    for (final String time in times) {
      items.add(DropdownMenuItem(
        value: time,
        child: Text(time),
      ));
    }
    return items;
  }

  Widget _showMeetingUrlLabel() {
    String title = 'common.set_url'.tr();
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }
  
  Widget _showMeetingUrlInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputBox(
          autofocus: false,
          hint: '',
          text: _meetingUrl,
          textCapitalization: TextCapitalization.none, 
          inputChangedCallback: _changeUrl
        ),
        if (_shouldShowError) _showError()
      ],
    ); 
  }

  Widget _showError() {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0, top: 5.0),
      child: Text(
        'common.set_url_error'.tr(args: [urlType]),
        style: const TextStyle(
          fontSize: 13.0,
          color: Colors.red
        )
      ),
    );
  }

  Widget _showStartCourseText() {
    String startCourseText = 'common.start_course_text'.tr(args:[AppConstants.minStudentsCourse.toString()]);
    startCourseText = startCourseText[0].toUpperCase() + startCourseText.substring(1);
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, top: 10.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.DOVE_GRAY,
            fontSize: 13.0
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'mentor_course.note'.tr() + ' ',
              style: const TextStyle(
                fontWeight: FontWeight.bold
              )
            ),
            TextSpan(
              text: startCourseText + '.'
            )
          ]
        )
      )
    );
  }     

  void _changeUrl(String url) {
    setState(() {
      _meetingUrl = url;
    });
    _setShouldShowError(false);    
  }

  void _setShouldShowError(bool showError) {
    setState(() {
      _shouldShowError = showError;
    });
  }    

  Widget _showButtons() {
    String actionButtonText = 'mentor_course.set_details'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 25.0, 12.0),
              child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
            ),
            onTap: () {
              Navigator.pop(context, false);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.JAPANESE_LAUREL,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(25.0, 12.0, 25.0, 12.0)
            ),
            child: !_isSchedulingCourse ? Text(
              actionButtonText,
              style: const TextStyle(color: Colors.white)
            ) : SizedBox(
              width: 67.0,
              child: ButtonLoader()
            ),
            onPressed: () async {
              await _scheduleCourse();
            }
          )
        ]
      )
    ); 
  }

  Future<void> _scheduleCourse() async {
    _changeUrl(Utils.setUrl(_meetingUrl));
    if (Utils.checkValidMeetingUrl(_meetingUrl) == false) {
      _setShouldShowError(true);
      return ;
    }    
    await _scheduleCourseWithoutPartner();
  }

  Future<void> _scheduleCourseWithoutPartner() async {
    _setIsSchedulingCourse(true);
    await widget.onSetCourseDetails!(_subfieldId as String, _availability, _meetingUrl);
    Navigator.pop(context, true);
  }

  void _setIsSchedulingCourse(bool isScheduling) {
    setState(() {
      _isSchedulingCourse = isScheduling;
    });  
  }  

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }    

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _unfocus();
      },
      child: _showEditCourseDetailsDialog()
    );
  }
}