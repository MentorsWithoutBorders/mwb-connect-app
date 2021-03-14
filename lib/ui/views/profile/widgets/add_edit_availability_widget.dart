import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class AddAvailability extends StatefulWidget {
  const AddAvailability({Key key, this.availability})
    : super(key: key); 

  final Availability availability;

  @override
  State<StatefulWidget> createState() => _AddAvailabilityState();
}

class _AddAvailabilityState extends State<AddAvailability> {
  ProfileViewModel _profileProvider;
  Availability _availability;
  bool _shouldShowError = false;
  final String _defaultDayOfWeek = Utils.translateDayOfWeekToEng(Utils.daysOfWeek[5]);
  final String _defaultTimeFrom = '10am';
  final String _defaultTimeTo = '2pm';

  @override
  @protected
  void initState() {
    super.initState();
    if (widget.availability != null) {
      _availability = widget.availability;
    } else {
      _availability = Availability(dayOfWeek: _defaultDayOfWeek, time: Time(from: _defaultTimeFrom, to: _defaultTimeTo));
    }    
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
        widget.availability == null ? 'Add availability' : 'Edit availability',
        style: const TextStyle(
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
          value: _availability.dayOfWeek
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

  void _setDayOfWeek(String dayOfWeek) {
    setState(() {
      _availability.dayOfWeek = dayOfWeek;
    });
  }

  Widget _showTimeDropdowns() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4.0, right: 3.0),
              child: Text('From')
            ),
            _showTimeFromDropdown(),
            const Padding(
              padding: EdgeInsets.fromLTRB(5.0, 4.0, 5.0, 0.0),
              child: Text('to')
            ),
            _showTimeToDropdown()
          ]
        ),
        if (_shouldShowError) _showError() 
      ],
    );
  }

  Widget _showError() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Text(
        '"From" time cannot be equal to or after "to" time',
        style: TextStyle(
          fontSize: 13.0,
          color: AppColors.MONZA
        )
      )
    );
  }
  
  Widget _showTimeFromDropdown() {
    return Container(
      width: 80,
      height: 30,
      margin: const EdgeInsets.only(top: 20.0, bottom: 15.0),
      child: Dropdown(
        dropdownMenuItemList: _buildTimeDropdown(),
        onTapped: _hideError,
        onChanged: _setTimeFrom,
        value: _availability.time.from
      ),
    );
  }

  void _hideError() {
    setState(() {
      _shouldShowError = false;
    });
  }

  void _setTimeFrom(String time) {
    setState(() {
      _availability.time.from = time;
    });
  }    

  Widget _showTimeToDropdown() {
    return Container(
      width: 80,
      height: 30,
      margin: const EdgeInsets.only(top: 20.0, bottom: 15.0),
      child: Dropdown(
        dropdownMenuItemList: _buildTimeDropdown(),
        onTapped: _hideError,
        onChanged: _setTimeTo,
        value: _availability.time.to
      ),
    );
  }
  
  void _setTimeTo(String time) {
    setState(() {
      _availability.time.to = time;
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
            child: Container(
              padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
              child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.MONZA,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0)
            ), 
            onPressed: () {
              widget.availability == null ? _addAvailability() : _updateAvailability();
            },
            child: Text(
              widget.availability == null ? 'Add' : 'Update',
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
    if (_profileProvider.isAvailabilityValid(_availability)) {
      Navigator.pop(context, true);
      _profileProvider.addAvailability(_availability);
    } else {
      setState(() {
        _shouldShowError = true;
      });
    }
  }

  void _updateAvailability() {
    if (_profileProvider.isAvailabilityValid(_availability)) {
      Navigator.pop(context, true);
      _profileProvider.updateAvailability(widget.availability, _availability);
    } else {
      setState(() {
        _shouldShowError = true;
      });
    }
  }  

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);      

    return _showAddAvailabilityDialog();
  }
}