import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
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
            key: Key(AppKeys.availabilityItem + widget.index.toString()),
            width: 220.0,
            child: Row(
              children: [
                Container(
                  width: 90.0,
                  child: Text(
                    '$dayOfWeek:',
                    style: const TextStyle(
                      color: AppColors.DOVE_GRAY
                    )
                  ),
                ),
                Container(
                  width: 100.0,
                  child: Text(
                    '$timeFrom - $timeTo',
                    style: const TextStyle(
                      color: AppColors.DOVE_GRAY
                    )
                  ),
                ),
                _showEditItem()
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

  Widget _showEditItem() {
    return Container(
      key: Key(AppKeys.editAvailabilityIcon + widget.index.toString()),
      width: 22.0,
      height: 22.0,
      child: Image.asset(
        'assets/images/edit_icon.png'
      ),
    );
  }   

  Widget _showDeleteItem() {
    return InkWell(
      key: Key(AppKeys.deleteAvailabilityBtn + widget.index.toString()),
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
        key: Key(AppKeys.toast),
        content: Text(_profileProvider.availabilityMergedMessage),
        action: SnackBarAction(
          label: 'Close', onPressed: scaffold.hideCurrentSnackBar
        ),
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showAvailabilityItem();
  }
}