import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class EditAvailability extends StatefulWidget {
  const EditAvailability({Key? key, @required this.index})
    : super(key: key); 

  final int? index;

  @override
  State<StatefulWidget> createState() => _EditAvailabilityState();
}

class _EditAvailabilityState extends State<EditAvailability> {
  ProfileViewModel? _profileProvider;
  Availability? _availability;
  bool _shouldShowError = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {  
      _profileProvider = Provider.of<ProfileViewModel>(context);
      _initAvalability();
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  void _initAvalability() {
    _availability = _profileProvider?.user?.availabilities?[widget.index!];
  }
  
  Widget _showEditAvailabilityDialog() {
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
        'profile.edit_availability'.tr(),
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 3.0),
              child: Text('profile.availability_from'.tr())
            ),
            _showTimeFromDropdown(),
            Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 4.0, 5.0, 0.0),
              child: Text('profile.availability_to'.tr())
            ),
            _showTimeToDropdown()
          ]
        ),
        if (_shouldShowError) _showError() 
      ],
    );
  }

  Widget _showError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Text(
        'profile.availability_error'.tr(),
        style: const TextStyle(
          fontSize: 13.0,
          color: AppColors.MONZA
        )
      )
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

  void _hideError() {
    setState(() {
      _shouldShowError = false;
    });
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
              _updateAvailability();
            },
            child: Text(
              'common.update'.tr(),
              style: const TextStyle(
                color: Colors.white
              )
            )
          )
        ]
      )
    ); 
  }

  void _updateAvailability() {
    if (_profileProvider?.isAvailabilityValid(_availability!) == true) {
      _profileProvider?.updateAvailability(widget.index!, _availability!);
      Navigator.pop(context, true);
    } else {
      setState(() {
        _shouldShowError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showEditAvailabilityDialog();
  }
}