import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';

class EditCourseDetailsDialog extends StatefulWidget {
  const EditCourseDetailsDialog({Key? key, @required this.selectedCourseType, @required this.subfields, @required this.setCourseDetailsCallback})
    : super(key: key); 

  final CourseType? selectedCourseType;
  final List<Subfield>? subfields;
  final Function(String, Availability?, String)? setCourseDetailsCallback;  

  @override
  State<StatefulWidget> createState() => _EditCourseDetailsDialogState();
}

class _EditCourseDetailsDialogState extends State<EditCourseDetailsDialog> {
  Availability? _availability;
  String? _subfieldId;
  String? _meetingUrl;
  bool _shouldShowError = false;  
  bool _isInit = false;
  final String _defaultDayOfWeek = Utils.translateDayOfWeekToEng(Utils.daysOfWeek[5]);
  final String _defaultTimeFrom = '10am';
  final String urlType = AppConstants.meetingUrlType;    

  @override
  void didChangeDependencies() {
    if (!_isInit) {  
      _initAvalability();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  void _initAvalability() {
    _availability = Availability(dayOfWeek: _defaultDayOfWeek, time: Time(from: _defaultTimeFrom));
  }
  
  Widget _showEditCourseDetailsDialogDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showSubfieldsLabel(),
          _showSubfieldsList(),
          if (widget.selectedCourseType?.isWithPartner == false) _showDayTimeLabel(),
          if (widget.selectedCourseType?.isWithPartner == false) _showDayTimeDropdowns(),
          _showMeetingUrlLabel(),
          _showMeetingUrlInput(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Center(
      child: Text(
        'mentor_course.set_course_details'.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showSubfieldsLabel() {
    String title = 'common.choose_subfield'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
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

  Widget _showSubfieldsList() {
    final List<Widget> subfieldWidgets = [];
    if (widget.subfields != null) {
      for (int i = 0; i < widget.subfields!.length; i++) {
        subfieldWidgets.add(_showSubfieldItem(widget.subfields![i]));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Wrap(
        children: subfieldWidgets
      )
    );
  }

  Widget _showSubfieldItem(Subfield subfield) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            child: Row(
              children: [
                _showRadioButton(subfield.id as String),
                _showSubfield(subfield)
              ],
            ),
            onTap: () {
              _setSubfieldId(subfield.id);
            }
          )
        )
      ]
    );
  }

  Widget _showRadioButton(String subfieldId) {
    return SizedBox(
      width: 40.0,
      height: 30.0,
      child: Radio<String>(
        value: subfieldId,
        groupValue: _subfieldId,
        onChanged: (String? value) {
          _setSubfieldId(value);
        }
      )
    );
  }

  void _setSubfieldId(String? value) {
    setState(() {
      _subfieldId = value;
    });
  }

  Widget _showSubfield(Subfield subfield) {
    final String subfieldName = subfield.name as String;
    return Expanded(
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        text: TextSpan(
          style: const TextStyle(
            color: AppColors.DOVE_GRAY,
            fontSize: 14.0
          ),
          children: <TextSpan>[
            TextSpan(
              text: subfieldName,
              style: const TextStyle(
                color: AppColors.DOVE_GRAY
              )
            )
          ]
        )
      )
    );
  }  
  
  Widget _showDayTimeLabel() {
    String title = 'common.choose_day_time_course'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
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

  Widget _showDayTimeDropdowns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _showDayOfWeekDropdown(),
        Padding(
          padding: const EdgeInsets.only(top: 4.0, right: 3.0),
          child: Text('common.availability_from'.tr().toLowerCase())
        ),
        _showTimeDropdown()
      ]
    );
  }

  Widget _showDayOfWeekDropdown() {
    return Center(
      child: Container(
        width: 150.0,
        height: 30.0,
        margin: const EdgeInsets.only(top: 20.0),
        child: Dropdown(
          key: const Key(AppKeys.dayOfWeekDropdown),
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
      width: 80.0,
      height: 30.0,
      margin: const EdgeInsets.only(top: 20.0, bottom: 15.0),
      child: Dropdown(
        key: const Key(AppKeys.timeFromDropdown),
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
    String title = 'common.set_meetingUrl'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
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
    return Container(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InputBox(
              autofocus: true, 
              hint: '',
              text: _meetingUrl as String,
              textCapitalization: TextCapitalization.none, 
              inputChangedCallback: _changeUrl
            ),
          ),
          if (_shouldShowError) _showError()
        ],
      )
    ); 
  }

  Widget _showError() {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Text(
        'common.send_meetingUrl_error'.tr(args: [urlType]),
        style: const TextStyle(
          fontSize: 12.0,
          color: Colors.red
        )
      ),
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
    String actionButtonText = widget.selectedCourseType?.isWithPartner as bool ? 'mentor_course.find_partner'.tr() : 'mentor_course.wait_students'.tr();    
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
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
              padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0)
            ), 
            onPressed: () {
              _scheduleCourse();
            },
            child: Text(
              actionButtonText,
              style: const TextStyle(
                color: Colors.white
              )
            )
          )
        ]
      )
    ); 
  }

  void _scheduleCourse() {
    Navigator.pop(context, true);
    if (widget.selectedCourseType?.isWithPartner == false) {
      _scheduleCourseWithoutPartner();
    } else {
      _scheduleCourseWithPartner();
    }
  }

  void _scheduleCourseWithoutPartner() {
    widget.setCourseDetailsCallback!(_subfieldId as String, _availability, _meetingUrl as String);
    Navigator.pop(context);
  }

  void _scheduleCourseWithPartner() {
    Navigator.pop(context);
    widget.setCourseDetailsCallback!(_subfieldId as String, null, _meetingUrl as String);
  }  

  @override
  Widget build(BuildContext context) {
    return _showEditCourseDetailsDialogDialog();
  }
}