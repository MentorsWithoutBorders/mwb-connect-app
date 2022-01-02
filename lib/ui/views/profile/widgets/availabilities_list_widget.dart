import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/timezone_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_item_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/add_availability_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class AvailabilitiesList extends StatefulWidget {
  const AvailabilitiesList({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _AvailabilitiesListState();
}

class _AvailabilitiesListState extends State<AvailabilitiesList> with TickerProviderStateMixin {
  ProfileViewModel? _profileProvider;

  Widget _showAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showTitle(),
        _showTimezone(),
        _showAvailabilitiesList(),
        _showAddAvailabilityButton()
      ]
    );
  }

  Widget _showTitle() {
    String title = _profileProvider?.user?.isMentor == true ? 'profile.available_days_times'.tr() : 'profile.availability'.tr();
    return Container(
      margin: const EdgeInsets.only(left: 5.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showTimezone() {
    return const UserTimezone();
  }

  Widget _showAvailabilitiesList() {
    final List<Widget> availabilityWidgets = [];
    final List<Availability>? availabilitiesList = _profileProvider?.user?.availabilities;
    if (availabilitiesList != null) {
      for (int i = 0; i < availabilitiesList.length; i++) {
        availabilityWidgets.add(AvailabilityItem(index: i));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
      child: Wrap(
        children: availabilityWidgets
      )
    );
  }

  Widget _showAddAvailabilityButton() {
    return Center(
      child: ElevatedButton(
        key: const Key(AppKeys.addAvailabilityBtn),
        style: ElevatedButton.styleFrom(
          elevation: 1.0,
          primary: AppColors.MONZA,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
        ), 
        child: Text('profile.add_availability'.tr(), style: const TextStyle(color: Colors.white)),
        onPressed: () {
          _showAddAvailabilityDialog();
        }
      ),
    );
  }

  void _showAddAvailabilityDialog() {
    _unfocus();
    showDialog(
      context: context,
      builder: (_) => const AnimatedDialog(
        widgetInside: AddAvailability()
      ),
    ).then((shouldShowToast) {
      if (shouldShowToast && _profileProvider?.availabilityMergedMessage.isNotEmpty == true) {
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
      
    return _showAvailability();
  }
}