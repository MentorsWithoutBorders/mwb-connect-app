import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/name_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfields_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_switch_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_list_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class ProfileView extends StatefulWidget {
  ProfileView({@required this.isMentor});

  final bool isMentor;
  
  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  ProfileViewModel _profileProvider;

  void _unfocus() {
    FocusScope.of(context).unfocus();    
  }

  Widget _showProfileCard(BuildContext context, Profile profile) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(15.0, 90.0, 15.0, 20.0), 
        child: Column(
          children: [
            Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ), 
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  children: [
                    Name(),
                    FieldDropdown(),
                    Subfields()
                  ],
                )
              ),
            ),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ), 
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  children: [
                    AvailabilitySwitch(),
                    AvailabilityList(),
                  ],
                )
              ),
            ), 
          ],
        ),
      ),
    );
  }
  
  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text('profile.title'.tr()),
      )
    );
  }
  
  Widget _showContent(BuildContext context, bool hasData, Profile profile) {
    if (hasData) {
      return _showProfileCard(context, profile);
    } else {
      return Loader();
    }
  }

  Future<Profile> _getProfile() async {
    final User user = await _profileProvider.getUserDetails();
    final List<Field> fields = await _profileProvider.getFields();
    return Profile(user: user, fields: fields);
  }  

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    if (_profileProvider.shouldUnfocus) {
      _unfocus();
      _profileProvider.shouldUnfocus = false;
    }

    return FutureBuilder(
      future: _getProfile(),
      builder: (BuildContext context, AsyncSnapshot<Profile> snapshot) {
        _profileProvider.profile = snapshot.data;
        return GestureDetector(
          onTap: () {
            _unfocus();
          },
          child: Stack(
            children: <Widget>[
              BackgroundGradient(),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: _showTitle(),
                  backgroundColor: Colors.transparent,          
                  elevation: 0.0
                ),
                extendBodyBehindAppBar: true,
                body: _showContent(context, snapshot.hasData, _profileProvider.profile)
              )
            ],
          )
        );
      }
    );
  }
}
