import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';

class UserTimezone extends StatefulWidget {
  const UserTimezone({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _UserTimezoneState();
}

class _UserTimezoneState extends State<UserTimezone> {
  ProfileViewModel _profileProvider;   

  Widget _showTimezone() {
    DateTime now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 12.0),
      child: Text(
        'All times are in ' + now.timeZoneName + ' timezone.',
        style: const TextStyle(
          fontSize: 13.0,
          color: AppColors.DOVE_GRAY,
          fontStyle: FontStyle.italic
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return Column(
      children: [
        if (_profileProvider.profile.user.availabilities.length > 0) _showTimezone(),
      ],
    );
  }
}