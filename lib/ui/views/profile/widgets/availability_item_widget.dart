import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/edit_availability_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class AvailabilityItem extends StatefulWidget {
  const AvailabilityItem({Key key, this.index})
    : super(key: key); 

  final int index;

  @override
  State<StatefulWidget> createState() => _AvailabilityItemState();
}

class _AvailabilityItemState extends State<AvailabilityItem> {
  ProfileViewModel _profileProvider;  

  Widget _showAvailabilityItem() {
    final Availability availability = _profileProvider.profile.user.availabilities[widget.index];
    final String dayOfWeek = availability.dayOfWeek;
    final String timeFrom = availability.time.from;
    final String timeTo = availability.time.to;
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
                    style: const TextStyle(
                      color: AppColors.DOVE_GRAY
                    )
                  ),
                ),
                Text(
                  '$timeFrom - $timeTo',
                  style: const TextStyle(
                    color: AppColors.DOVE_GRAY
                  )
                )
              ],
            ),
          ),
          onTap: () {
            _showEditAvailabilityDialog(availability);
          },
        ),
        _showDeleteItem()
      ]
    );
  }

  void _showEditAvailabilityDialog(Availability availability) {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: EditAvailability(index: widget.index),
        hasInput: true,
      )
    ).then((shouldShowToast) {
      if (shouldShowToast && _profileProvider.availabilityMergedMessage.isNotEmpty) {
        _showToast(context);
        _profileProvider.resetAvailabilityMergedMessage();
      }
    });     
  }

  void _showToast(BuildContext context) {
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(_profileProvider.availabilityMergedMessage),
        action: SnackBarAction(
          label: 'Close', onPressed: scaffold.hideCurrentSnackBar
        ),
      ),
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