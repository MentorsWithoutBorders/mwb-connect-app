import 'package:flutter/material.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/label_widget.dart';
import 'package:mwb_connect_app/ui/widgets/dropdown_widget.dart';

class Lessons extends StatefulWidget {
  const Lessons({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _LessonsState();
}

class _LessonsState extends State<Lessons> {
  ProfileViewModel _profileProvider;
  int _selectedMaxLessons;
  int _selectedMinInterval;
  String _selectedMaxLessonsUnit;
  String _selectedMinIntervalUnit;

  Widget _showLessons() {
    return Wrap(
      children: [
        _showTitle(),
        Container(
          padding: const EdgeInsets.only(left: 3.0),
          child: Wrap(
            children: [
              Label(text: 'I want to do a maximum of:'),
              _showMaxLessons(),
              Label(text: 'Minimum interval between lessons:'),
              _showMinInterval()
            ]
          )
        )
      ]
    );
  }

  Widget _showMaxLessons() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 50.0,
            height: 45.0,
            margin: const EdgeInsets.only(left: 2.0),
            padding: const EdgeInsets.only(bottom: 15),
            child: Dropdown(
              key: const Key(AppKeys.maxLessonsDropdown),
              dropdownMenuItemList: _buildNumbers(),
              onTapped: _unfocus,
              onChanged: _changeMaxLessons,
              value: _selectedMaxLessons
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
            child: Text(
              'lessons per',
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.DOVE_GRAY
              )
            )
          ),
          Container(
            width: 90.0,
            height: 45.0,
            padding: const EdgeInsets.only(bottom: 15),
            child: Dropdown(
              key: const Key(AppKeys.maxLessonsUnitDropdown),
              dropdownMenuItemList: _buildPeriodUnitsDropdown(),
              onTapped: _unfocus,
              onChanged: _changeMaxLessonsUnit,
              value: _selectedMaxLessonsUnit
            ),
          ),
        ]
      )
    );
  }

  List<DropdownMenuItem<int>> _buildNumbers() {
    final List<DropdownMenuItem<int>> items = [];
    for (int i = 1; i < 10; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text(i.toString()),
      ));
    }
    return items;
  }

  List<DropdownMenuItem<String>> _buildPeriodUnitsDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    for (final String periodUnit in Utils.periodUnits) {
      items.add(DropdownMenuItem(
        value: periodUnit,
        child: Text(periodUnit),
      ));
    }
    return items;
  }

  void _changeMaxLessons(int i) {
    _setSelectedMaxLessons(i);
    _updateLessonsAvailability();
  }
  
  void _setSelectedMaxLessons(int i) {
    setState(() {
      _selectedMaxLessons = i;
    });
  }

  void _changeMaxLessonsUnit(String unit) {
    _setSelectedMaxLessonsUnit(unit);
    _updateLessonsAvailability();
  }
  
  void _setSelectedMaxLessonsUnit(unit) {
    setState(() {
      _selectedMaxLessonsUnit = unit;
    });
  }

  Widget _showMinInterval() {
    return Row(
      children: [
        Container(
          width: 50.0,
          height: 45.0,
          margin: const EdgeInsets.only(left: 2.0),            
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Dropdown(
            key: const Key(AppKeys.maxLessonsDropdown),
            dropdownMenuItemList: _buildNumbers(),
            onTapped: _unfocus,
            onChanged: _changeMinInterval,
            value: _selectedMinInterval
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10.0)
        ),
        Container(
          width: 100.0,
          height: 45.0,
          padding: const EdgeInsets.only(bottom: 15),
          child: Dropdown(
            key: const Key(AppKeys.minIntervalUnitDropdown),
            dropdownMenuItemList: _buildPeriodUnitsDropdown(),
            onTapped: _unfocus,
            onChanged: _changeMinIntervalUnit,
            value: _selectedMinIntervalUnit
          ),
        ),
      ]
    );
  } 
  
  void _changeMinInterval(int i) {
    _setSelectedMinInterval(i);
    _updateLessonsAvailability();
  }
  
  void _setSelectedMinInterval(int i) {
    setState(() {
      _selectedMinInterval = i;
    });
  }
  
  void _changeMinIntervalUnit(String unit) {
    _setSelecteddMinIntervalUnit(unit);
    _updateLessonsAvailability();
  }
  
  void _setSelecteddMinIntervalUnit(unit) {
    setState(() {
      _selectedMinIntervalUnit = unit;
    });
  }  

  void _unfocus() {
    _profileProvider.shouldUnfocus = true;
  }

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 5.0, bottom: 18.0),
      child: const Text(
        'Lessons',
        style: TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }
  
  void _setSelectedValues(LessonsAvailability lessonsAvailability) {
    setState(() {
      _selectedMaxLessons = lessonsAvailability.maxLessons;
      _selectedMaxLessonsUnit = lessonsAvailability.maxLessonsUnit;
      _selectedMinInterval = lessonsAvailability.minInterval;
      _selectedMinIntervalUnit = lessonsAvailability.minIntervalUnit;
    });
  }

  void _updateLessonsAvailability() {
    LessonsAvailability lessonsAvailability = LessonsAvailability(
      maxLessons: _selectedMaxLessons,
      maxLessonsUnit: _selectedMaxLessonsUnit,
      minInterval: _selectedMinInterval,
      minIntervalUnit: _selectedMinIntervalUnit
    );
    _profileProvider.updateLessonsAvailability(lessonsAvailability);
  }

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);
    _setSelectedValues(_profileProvider.getLessonsAvailability());

    return _showLessons();
  }
}