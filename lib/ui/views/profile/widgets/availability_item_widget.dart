import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/edit_availability_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class AvailabilityItem extends StatefulWidget {
  const AvailabilityItem({Key? key, @required this.index})
    : super(key: key); 

  final int? index;

  @override
  State<StatefulWidget> createState() => _AvailabilityItemState();
}

class _AvailabilityItemState extends State<AvailabilityItem> {
  ProfileViewModel? _profileProvider;  

  Widget _showAvailabilityItem() {
    final Availability? availability = _profileProvider?.user?.availabilities?[widget.index!];
    final String? dayOfWeek = availability?.dayOfWeek;
    final String? timeFrom = availability?.time?.from;
    final String? timeTo = availability?.time?.to;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            key: Key(AppKeys.availabilityItem + widget.index.toString()),              
            child: Row(
              children: [
                _showDayOfWeek(dayOfWeek!),
                _showTimes(timeFrom!, timeTo!),
                _showEditItem()
              ],
            ),
            onTap: () {
              _showEditAvailabilityDialog(availability!);
            }
          )
        ),
        _showDeleteItem()
      ]
    );
  }

  Widget _showDayOfWeek(String dayOfWeek) {
    return Container(
      width: 90.0,
      child: Text(
        '$dayOfWeek:',
        style: const TextStyle(
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  Widget _showTimes(String timeFrom, String timeTo) {
    return Expanded(
      child: Text(
        '$timeFrom - $timeTo',
        style: const TextStyle(
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  Widget _showEditItem() {
    return Container(
      key: Key(AppKeys.editAvailabilityIcon + widget.index.toString()),
      height: 22.0,
      padding: const EdgeInsets.only(right: 5.0),
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
      onTap: () {
        _deleteAvailability();
      } 
    );
  }
  
  void _deleteAvailability() {
    _unfocus();
    _profileProvider?.deleteAvailability(widget.index!);    
  }

  void _showEditAvailabilityDialog(Availability availability) {
    _unfocus();
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: EditAvailability(index: widget.index)
      )
    ).then((shouldShowToast) {
      if (shouldShowToast != null && shouldShowToast && _profileProvider?.availabilityMergedMessage.isNotEmpty == true) {
        _showToast(context);
        _profileProvider?.resetAvailabilityMergedMessage();
      }
    });     
  }

  void _showToast(BuildContext context) {
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        key: const Key(AppKeys.toast),
        content: Text(_profileProvider?.availabilityMergedMessage as String),
        action: SnackBarAction(
          label: 'common.close'.tr(), onPressed: scaffold.hideCurrentSnackBar
        ),
      ),
    );
  }
  
  void _unfocus() {
    _profileProvider?.shouldUnfocus = true;
  }   

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showAvailabilityItem();
  }
}