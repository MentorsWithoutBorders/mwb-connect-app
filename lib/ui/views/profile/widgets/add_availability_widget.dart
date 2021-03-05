import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class AddAvailability extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddAvailabilityState();
}

class _AddAvailabilityState extends State<AddAvailability> {
  ProfileViewModel _profileProvider;
  Availability availability;

  @protected
  void initState() {
    super.initState();
    availability = Availability(dayOfWeek: 'Saturday', time: Time(from: '10am', to: '2pm'));
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
        'Add availability',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showDayOfWeekDropdown() {
    return Center(
      child: Container(
        width: 150,
        height: 30,
        margin: const EdgeInsets.only(top: 20.0),
        child: Dropdown(
          dropdownMenuItemList: _buildDayOfWeekDropdown(),
          onChanged: _setDayOfWeek,
          value: availability.dayOfWeek
        ),
      ),
    );
  }

 List<DropdownMenuItem<String>> _buildDayOfWeekDropdown() {
    List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    List<DropdownMenuItem<String>> items = List();
    for (String day in daysOfWeek) {
      items.add(DropdownMenuItem(
        value: day,
        child: Text(day),
      ));
    }
    return items;
  }  

  void _setDayOfWeek(String dayOfWeek) {
    setState(() {
      availability.dayOfWeek = dayOfWeek;
    });
  }

  Widget _showTimeDropdowns() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 3.0),
              child: Text('From')
            ),
            _showTimeFromDropdown(),
            Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 4.0, 5.0, 0.0),
              child: Text('to')
            ),
            _showTimeToDropdown()
          ]
        ),
        if (!_profileProvider.isAvailabilityValid(availability)) Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            '"From" time cannot be equal to or after "to" time',
            style: TextStyle(
              fontSize: 13.0,
              color: AppColors.MONZA
            ) 
          )
        )
      ],
    );
  }
  
  Widget _showTimeFromDropdown() {
    return Container(
      width: 80,
      height: 30,
      margin: const EdgeInsets.only(top: 20.0, bottom: 15.0),
      child: Dropdown(
        dropdownMenuItemList: _buildTimeDropdown(),
        onChanged: _setTimeFrom,
        value: availability.time.from
      ),
    );
  }

  void _setTimeFrom(String time) {
    setState(() {
      availability.time.from = time;
    });
  }    

  Widget _showTimeToDropdown() {
    return Container(
      width: 80,
      height: 30,
      margin: const EdgeInsets.only(top: 20.0, bottom: 15.0),
      child: Dropdown(
        dropdownMenuItemList: _buildTimeDropdown(),
        onChanged: _setTimeTo,
        value: availability.time.to
      ),
    );
  }
  
  void _setTimeTo(String time) {
    setState(() {
      availability.time.to = time;
    });
  }    
  
  List<DropdownMenuItem<String>> _buildTimeDropdown() {
    List<String> times = ['12am', '1am', '2am', '3am', '4am', '5am', '6am', '7am', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '6pm', '7pm', '8pm', '9pm', '10pm', '11pm'];
    List<DropdownMenuItem<String>> items = List();
    for (String time in times) {
      items.add(DropdownMenuItem(
        value: time,
        child: Text(time),
      ));
    }
    return items;
  }

  Widget _showButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            child: Container(
              padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
              child: Text('common.cancel'.tr(), style: TextStyle(color: Colors.grey))
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          RaisedButton(
            padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0),
            splashColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            onPressed: () {
              _addAvailability();
            },
            child: Text('Add', style: TextStyle(color: Colors.white)),
            color: AppColors.MONZA
          )
        ]
      )
    ); 
  }

  void _addAvailability() {
    if (_profileProvider.isAvailabilityValid(availability)) {
      _profileProvider.addAvailability(availability);
      Navigator.pop(context);
    }    
  }

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);      

    return _showAddAvailabilityDialog();
  }
}