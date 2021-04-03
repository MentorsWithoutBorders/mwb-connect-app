import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
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
  LessonsAvailability _lessonsAvailability;

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
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Dropdown(
              key: const Key(AppKeys.maxLessonsDropdown),
              dropdownMenuItemList: _buildNumbers(),
              onTapped: _unfocus,
              onChanged: _changeMaxLessons,
              value: _lessonsAvailability.maxLessons
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
            width: 130.0,
            height: 45.0,
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Dropdown(
              key: const Key(AppKeys.maxLessonsUnitDropdown),
              dropdownMenuItemList: _buildMaxLessonsUnitsDropdown(),
              onTapped: _unfocus,
              onChanged: _changeMaxLessonsUnit,
              value: _lessonsAvailability.maxLessonsUnit
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

  List<DropdownMenuItem<String>> _buildMaxLessonsUnitsDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    for (final String periodUnit in Utils.periodUnits) {
      items.add(DropdownMenuItem(
        value: periodUnit,
        child: Text(periodUnit)
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
      _lessonsAvailability.maxLessons = i;
    });
  }

  void _changeMaxLessonsUnit(String unit) {
    _setSelectedMaxLessonsUnit(unit);
    _updateLessonsAvailability();
  }
  
  void _setSelectedMaxLessonsUnit(unit) {
    setState(() {
      _lessonsAvailability.maxLessonsUnit = unit;
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
            value: _lessonsAvailability.minInterval
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
            dropdownMenuItemList: _buildMinIntervalUnitsDropdown(),
            onTapped: _unfocus,
            onChanged: _changeMinIntervalUnit,
            value: _profileProvider.getPeriodUnitPlural(_lessonsAvailability.minIntervalUnit, _lessonsAvailability.minInterval)
          ),
        ),
      ]
    );
  }
  
  List<DropdownMenuItem<String>> _buildMinIntervalUnitsDropdown() {
    final List<DropdownMenuItem<String>> items = [];
    for (final String periodUnit in Utils.periodUnits) {
      items.add(DropdownMenuItem(
        value: _profileProvider.getPeriodUnitPlural(periodUnit, _lessonsAvailability.minInterval),
        child: Text(_profileProvider.getPeriodUnitPlural(periodUnit, _lessonsAvailability.minInterval)))
      );
    }
    return items;
  }
  
  void _changeMinInterval(int interval) {
    _setSelectedMinInterval(interval);
    _updateLessonsAvailability();
  }
  
  void _setSelectedMinInterval(int interval) {
    setState(() {
      _lessonsAvailability.minInterval = interval;
    });
  }
  
  void _changeMinIntervalUnit(String unit) {
    _setSelectedMinIntervalUnit(unit);
    _updateLessonsAvailability();
  }
  
  void _setSelectedMinIntervalUnit(unit) {
    setState(() {
      _lessonsAvailability.minIntervalUnit = _profileProvider.getPeriodUnitPlural(unit, _lessonsAvailability.minInterval);
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
  
  void _setLessonsAvailability() {
    setState(() {
      _lessonsAvailability = _profileProvider.profile.user.lessonsAvailability;
    });
  }

  void _updateLessonsAvailability() {
    _lessonsAvailability.minIntervalUnit = _profileProvider.getPeriodUnitSingular(_lessonsAvailability.minIntervalUnit, _lessonsAvailability.minInterval);
    _profileProvider.updateLessonsAvailability(_lessonsAvailability);
  }

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);
    _setLessonsAvailability();

    return _showLessons();
  }
}