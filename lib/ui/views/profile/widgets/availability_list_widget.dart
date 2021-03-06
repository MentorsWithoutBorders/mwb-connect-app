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
  @override
  State<StatefulWidget> createState() => _AvailabilityListState();
}

class _AvailabilityListState extends State<AvailabilityList> with TickerProviderStateMixin {
  ProfileViewModel _profileProvider;

  Widget _showAvailability() {
    bool isAvailable = _profileProvider.profile.user.isAvailable;
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      child: Container(
        child: !isAvailable ?
          null 
          : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 1,
              margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              color: AppColors.BOTTICELLI
            ),
            Container(
              margin: const EdgeInsets.only(left: 5.0, bottom: 5.0),
              child: Text(
                'Availability',
                style: TextStyle(
                  color: AppColors.TANGO,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
              child: _showAvailabilityList()
            ),
            _showAddAvailabilityButton()
          ]
        ),
      ),
    );
  }

  Widget _showAvailabilityList() {
    List<Widget> availabilityWidgets = List();
    List<Availability> availabilityList = _profileProvider.profile.user.availabilities;
    for (int i = 0; i < availabilityList.length; i++) {
      availabilityWidgets.add(AvailabilityItem(index: i));
    }
    return Wrap(children: availabilityWidgets);
  }

  Widget _showAddAvailabilityButton() {
    return Center(
      child: RaisedButton(
        elevation: 1.0,
        padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
        splashColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        color: AppColors.MONZA,
        child: Text('Add availability', style: TextStyle(color: Colors.white)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AnimatedDialog(
              widgetInside: AddAvailability(),
              hasInput: true,
            ),
          );          
        }
      ),
    );
  }   

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);      

    return _showAvailability();
  }
}