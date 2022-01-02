import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/availability_item_widget.dart';

class AvailabilitiesList extends StatefulWidget {
  const AvailabilitiesList({Key? key, @required this.mentorId, @required this.availabilities})
    : super(key: key); 

  final String? mentorId;
  final List<Availability>? availabilities;

  @override
  State<StatefulWidget> createState() => _AvailabilitiesListState();
}

class _AvailabilitiesListState extends State<AvailabilitiesList> with TickerProviderStateMixin {
  Widget _showAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showTitle(),
        _showAvailabilitiesList()
      ]
    );
  }

  Widget _showTitle() {
    String title = 'available_mentors.choose_availability'.tr();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showAvailabilitiesList() {
    final List<Widget> availabilityWidgets = [];
    if (widget.availabilities != null) {
      for (int i = 0; i < widget.availabilities!.length; i++) {
        String mentorId = widget.mentorId as String;
        String id = mentorId + '-a-' + i.toString();
        availabilityWidgets.add(AvailabilityItem(id: id, availability: widget.availabilities![i]));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Wrap(
        children: availabilityWidgets
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showAvailability();
  }
}