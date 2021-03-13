import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/add_edit_availability_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class AvailabilityItem extends StatefulWidget {
  AvailabilityItem({@required this.index});

  final int index;

  @override
  State<StatefulWidget> createState() => _AvailabilityItemState();
}

class _AvailabilityItemState extends State<AvailabilityItem> {
  ProfileViewModel _profileProvider;  

  Widget _showAvailabilityItem() {
    Availability availability = _profileProvider.profile.user.availabilities[widget.index];
    String dayOfWeek = availability.dayOfWeek;
    String timeFrom = availability.time.from;
    String timeTo = availability.time.to;
    return Row(
      children: [
        InkWell(
          child: Container(
            width: 190.0,
            child: Row(
              children: [
                Container(
                  width: 90,
                  child: Text(
                    '$dayOfWeek:',
                    style: TextStyle(
                      color: AppColors.DOVE_GRAY
                    )
                  ),
                ),
                Text(
                  '$timeFrom - $timeTo',
                  style: TextStyle(
                    color: AppColors.DOVE_GRAY
                  )
                )
              ],
            ),
          ),
          onTap: () {
            _showAddAvailabilityDialog(availability);
          },
        ),
        _showDeleteItem()
      ]
    );
  }

  void _showAddAvailabilityDialog(Availability availability) {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: AddAvailability(availability: availability),
        hasInput: true,
      )
    );     
  }

  Widget _showDeleteItem() {
    return InkWell(
      child: Container(
        width: 30.0,
        height: 30.0,
        child: Image.asset(
          'assets/images/delete_icon.png'
        ),
      ),
      onTap: () => _profileProvider.deleteAvailability(widget.index)
    );
  }

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showAvailabilityItem();
  }
}