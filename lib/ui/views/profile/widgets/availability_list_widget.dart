import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_item_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/add_availability_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class AvailabilityList extends StatefulWidget {
  const AvailabilityList({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _AvailabilityListState();
}

class _AvailabilityListState extends State<AvailabilityList> with TickerProviderStateMixin {
  ProfileViewModel _profileProvider;

  Widget _showAvailability() {
    final bool isAvailable = _profileProvider.profile.user.isAvailable;
    return AnimatedSize(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      child: Container(
        child: !isAvailable ?
          null 
          : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _showDivider(),
            _showTitle(),
            _showAvailabilityList(),
            _showAddAvailabilityButton()
          ]
        ),
      ),
    );
  }

  Widget _showDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      color: AppColors.BOTTICELLI
    );
  }  

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 5.0, bottom: 8.0),
      child: const Text(
        'Availability',
        style: TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showAvailabilityList() {
    final List<Widget> availabilityWidgets = [];
    final List<Availability> availabilityList = _profileProvider.profile.user.availabilities;
    for (int i = 0; i < availabilityList.length; i++) {
      availabilityWidgets.add(AvailabilityItem(index: i));
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
        child: const Text('Add availability', style: TextStyle(color: Colors.white)),
        onPressed: () {
          _showAddAvailabilityDialog();
        }
      ),
    );
  }

  void _showAddAvailabilityDialog() {
    showDialog(
      context: context,
      builder: (_) => const AnimatedDialog(
        widgetInside: AddAvailability(),
        hasInput: true,
      ),
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
      
    return _showAvailability();
  }
}