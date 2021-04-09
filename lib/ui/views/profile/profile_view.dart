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
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_start_date_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_list_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/lessons_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class ProfileView extends StatefulWidget {
  ProfileView();

  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  ProfileViewModel _profileProvider;

  Widget _showProfileCard(Profile profile) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(20.0, statusBarHeight + 55.0, 20.0, 20.0), 
        child: Column(
          children: [
            _showPrimaryCard(),
            _showAvailabilityCard(),
            if (_profileProvider.profile.user.isMentor) _showLessonsCard()
          ],
        ),
      ),
    );
  }

  Widget _showPrimaryCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ), 
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Name(),
            if (_profileProvider.profile.user.isMentor) FieldDropdown(),
            if (_profileProvider.profile.user.isMentor) Subfields()
          ],
        )
      ),
    );
  }

  Widget _showAvailabilityCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ), 
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            AvailabilityStartDate(),
            AvailabilityList(),
          ],
        )
      ),
    );
  }

 Widget _showLessonsCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ), 
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Lessons()
          ],
        )
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
  
  Widget _showContent(bool hasData, Profile profile) {
    if (hasData) {
      return _showProfileCard(profile);
    } else {
      return Loader();
    }
  }

  Future<Profile> _getProfile() async {
    final User user = await _profileProvider.getUserDetails();
    final List<Field> fields = await _profileProvider.getFields();
    return Profile(user: user, fields: fields);
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }    

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    if (_profileProvider.shouldUnfocus) {
      _unfocus();
      _profileProvider.shouldUnfocus = false;
    }

    return FutureBuilder<Profile>(
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
                body: _showContent(snapshot.hasData, _profileProvider.profile)
              )
            ],
          )
        );
      }
    );
  }
}
