import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';

class AvailabilityItem extends StatefulWidget {
  const AvailabilityItem({Key? key, @required this.id, @required this.availability})
    : super(key: key); 

  final String? id;
  final Availability? availability;

  @override
  State<StatefulWidget> createState() => _AvailabilityItemState();
}

class _AvailabilityItemState extends State<AvailabilityItem> {
  AvailableMentorsViewModel? _availableMentorsProvider;

  Widget _showAvailabilityItem() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            child: Row(
              children: [
                _showRadioButton(),
                _showDayOfWeek(),
                _showTimes()
              ],
            ),
            onTap: () {
              _setAvailabilityOption(widget.id);
            }
          )
        )
      ]
    );
  }

  Widget _showRadioButton() {
    return SizedBox(
      width: 40.0,
      height: 30.0,
      child: Radio<String>(
        value: widget.id as String,
        groupValue: _availableMentorsProvider?.availabilityOptionId,
        onChanged: (String? value) {
          _setAvailabilityOption(value);
        }
      )
    );
  }

  void _setAvailabilityOption(String? value) {
    _availableMentorsProvider?.setAvailabilityOptionId(value);
    _availableMentorsProvider?.setErrorMessage('');
  }

  Widget _showDayOfWeek() {
    final String? dayOfWeek = widget.availability?.dayOfWeek;   
    return Container(
      width: 85.0,
      child: Text(
        '$dayOfWeek:',
        style: const TextStyle(
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  Widget _showTimes() {
    final String? timeFrom = widget.availability?.time?.from;
    final String? timeTo = widget.availability?.time?.to;     
    return Expanded(
      child: Text(
        '$timeFrom - $timeTo',
        style: const TextStyle(
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return _showAvailabilityItem();
  }
}