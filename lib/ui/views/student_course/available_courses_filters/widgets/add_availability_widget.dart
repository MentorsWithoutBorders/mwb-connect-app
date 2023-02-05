import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class AddAvailability extends StatefulWidget {
  const AddAvailability({Key? key, this.onAdd})
    : super(key: key);
    
  final Function(Availability)? onAdd;

  @override
  State<StatefulWidget> createState() => _AddAvailabilityState();
}

class _AddAvailabilityState extends State<AddAvailability> {
  Availability? _availability;
  bool _shouldShowError = false;
  final String _defaultDayOfWeek = Utils.translateDayOfWeekToEng(Utils.daysOfWeek[5]);
  final String _defaultTimeFrom = '10am';
  final String _defaultTimeTo = '2pm';

  @override
  void initState() {
    super.initState();
    _initAvalability();
  }
  
  void _initAvalability() {
    _availability = Availability(dayOfWeek: _defaultDayOfWeek, time: Time(from: _defaultTimeFrom, to: _defaultTimeTo));
  }  

  Widget _showAddAvailabilityDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showDayOfWeekDropdown(),
          _showTimeDropdowns(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Center(
      child: Text(
        'common.add_availability'.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold
        )
      )
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

  Widget _showTimeDropdowns() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 3.0),
              child: Text('common.availability_from'.tr())
            ),
            _showTimeFromDropdown(),
            Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 4.0, 5.0, 0.0),
              child: Text('common.availability_to'.tr())
            ),
            _showTimeToDropdown()
          ]
        ),
        if (_shouldShowError) _showError() 
      ],
    );
  }

  Widget _showTimeFromDropdown() {
    return Container(
      width: 80.0,
      height: 30.0,
      margin: const EdgeInsets.only(top: 20.0, bottom: 15.0),
      child: Dropdown(
        key: const Key(AppKeys.timeFromDropdown),
        dropdownMenuItemList: _buildTimeDropdown(),
        onTapped: _hideError,
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
  
  Widget _showTimeToDropdown() {
    return Container(
      width: 80.0,
      height: 30.0,
      margin: const EdgeInsets.only(top: 20.0, bottom: 15.0),
      child: Dropdown(
        key: const Key(AppKeys.timeToDropdown),
        dropdownMenuItemList: _buildTimeDropdown(),
        onTapped: _hideError,
        onChanged: _setTimeTo,
        value: _availability?.time?.to
      ),
    );
  }
  
  void _setTimeTo(String? time) {
    setState(() {
      _availability?.time?.to = time;
    });
  }     

  Widget _showError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        'common.availability_error'.tr(),
        style: TextStyle(
          fontSize: 13.0,
          color: AppColors.MONZA
        )
      )
    );
  }

  void _hideError() {
    setState(() {
      _shouldShowError = false;
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

  Widget _showButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            key: const Key(AppKeys.cancelBtn),
            child: Container(
              padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
              child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
            ),
            onTap: () {
              Navigator.pop(context, false);
            },
          ),
          ElevatedButton(
            key: const Key(AppKeys.submitBtn),
            style: ElevatedButton.styleFrom(
              primary: AppColors.MONZA,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0)
            ), 
            onPressed: () {
              _addAvailability();
            },
            child: Text(
              'common.add'.tr(),
              style: const TextStyle(
                color: Colors.white
              )
            )
          )
        ]
      )
    ); 
  }

  void _addAvailability() {
    if (UtilsAvailabilities.isAvailabilityValid(_availability!) == true) {
      widget.onAdd!(_availability!);
      Navigator.pop(context, true);
    } else {
      setState(() {
        _shouldShowError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showAddAvailabilityDialog();
  }
}