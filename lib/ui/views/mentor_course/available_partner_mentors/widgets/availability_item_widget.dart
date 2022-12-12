import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_partner_mentors_view_model.dart';

class AvailabilityItem extends StatefulWidget {
  const AvailabilityItem({Key? key, @required this.id, @required this.availability})
    : super(key: key); 

  final String? id;
  final Availability? availability;

  @override
  State<StatefulWidget> createState() => _AvailabilityItemState();
}

class _AvailabilityItemState extends State<AvailabilityItem> {
  AvailablePartnerMentorsViewModel? _availablePartnerMentorsProvider;

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
        groupValue: _availablePartnerMentorsProvider?.availabilityOptionId,
        onChanged: (String? value) {
          _setAvailabilityOption(value);
        }
      )
    );
  }

  void _setAvailabilityOption(String? value) {
    _availablePartnerMentorsProvider?.setAvailabilityOptionId(value);
    _availablePartnerMentorsProvider?.setErrorMessage('');
  }

  Widget _showDayOfWeek() {
    final String? dayOfWeek = widget.availability?.dayOfWeek;   
    return Container(
      width: 87.0,
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
    _availablePartnerMentorsProvider = Provider.of<AvailablePartnerMentorsViewModel>(context);

    return _showAvailabilityItem();
  }
}