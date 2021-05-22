import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }  

  Widget _showProfile(Profile profile) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
      child: ListView(
        key: const Key(AppKeys.profileListView),
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          _showPrimaryCard(),
          // _showAvailabilityCard(),
          // if (_profileProvider.profile.user.isMentor) _showLessonsCard()
        ]
      )
    );
  }

  void _scrollToPosition(double offset) {
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      _scrollController.animateTo(
        _scrollController.position.pixels + offset,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  Widget _showPrimaryCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.only(bottom: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), 
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              const Name(),
              // if (_profileProvider.profile.user.isMentor) const FieldDropdown(),
              // if (_profileProvider.profile.user.isMentor) const Subfields()
            ],
          )
        ),
      ),
    );
  }

  Widget _showAvailabilityCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.only(bottom: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), 
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              if (_profileProvider.profile.user.isMentor) AvailabilityStartDate(),
              if (_profileProvider.profile.user.isMentor) _showDivider(),
              AvailabilityList(),
            ],
          )
        ),
      ),
    );
  }

  Widget _showDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: 20.0),
      color: AppColors.BOTTICELLI
    );
  }    

  Widget _showLessonsCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.only(bottom: 20.0),
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
      return _showProfile(profile);
    } else {
      return const Loader();
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

    if (_profileProvider.scrollOffset != 0) {
      _scrollToPosition(_profileProvider.scrollOffset);
      _profileProvider.scrollOffset = 0;
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
              const BackgroundGradient(),
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
