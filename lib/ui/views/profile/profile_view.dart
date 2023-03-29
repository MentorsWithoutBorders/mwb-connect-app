import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/name_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfields_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_start_date_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availabilities_list_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/lessons_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/delete_account_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key, this.logoutCallback})
    : super(key: key);   

  final VoidCallback? logoutCallback;

  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  ProfileViewModel? _profileProvider;
  CommonViewModel? _commonProvider;
  final ScrollController _scrollController = ScrollController();
  bool _isProfileRetrieved = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }  

  Widget _showProfile() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
      child: ListView(
        key: const Key(AppKeys.profileListView),
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          _showPrimaryCard(),
          _showAvailabilityCard(),
          if (_profileProvider?.user?.isMentor == true) _showLessonsCard(),
          if (Platform.isIOS) _showDeleteAccountButton()
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
              if (_profileProvider?.user?.isMentor == true) const FieldDropdown(),
              if (_profileProvider?.user?.isMentor == true) const Subfields()
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
              if (_profileProvider?.user?.isMentor == true) AvailabilityStartDate(),
              if (_profileProvider?.user?.isMentor == true) _showDivider(),
              AvailabilitiesList(),
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
    double marginBottom = 20.0;
    if (Platform.isIOS) {
      marginBottom = 15.0;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: EdgeInsets.only(bottom: marginBottom),
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
        child: Text(
          'profile.title'.tr(),
          textAlign: TextAlign.center
        )
      )
    );
  }
  
  Widget _showContent() {
    if (_isProfileRetrieved) {
      return _showProfile();
    } else {
      return const Loader();
    }
  }

  Widget _showDeleteAccountButton() {
    return Container(
      alignment: Alignment.topLeft,
      margin: const EdgeInsets.only(left: 5.0, bottom: 20.0),
      child: SizedBox(
        width: 150.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0)
          ), 
          onPressed: () {
            _deleteAccount();
          },
          child: Text(
            'profile.delete_account'.tr(),
            style: const TextStyle(
              color: AppColors.MONZA
            )
          )
        ),
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: DeleteAccountDialog(logoutCallback: widget.logoutCallback)
      ),
    ).then((shouldGoBack) {
      if (shouldGoBack == true) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }); 
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  void _afterLayout(_) {
    if (_profileProvider?.shouldUnfocus == true) {
      _unfocus();
      _profileProvider?.shouldUnfocus = false;
    }

    if (_profileProvider?.scrollOffset != 0) {
      _scrollToPosition(_profileProvider?.scrollOffset as double);
      _profileProvider?.scrollOffset = 0;
    }
  }

  Future<void> _getProfile() async {
    if (!_isProfileRetrieved && _profileProvider != null) {
      await Future.wait([
        _profileProvider!.getUserDetails(),
        _profileProvider!.getFields()
      ]);      
      _isProfileRetrieved = true;
    }
  }
  
  Future<bool> _onWillPop(BuildContext context) async {
    _commonProvider?.setUser(_profileProvider?.user);
    return true;
  }  

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);
    _commonProvider = Provider.of<CommonViewModel>(context);

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: FutureBuilder<void>(
        future: _getProfile(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
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
                  body: _showContent()
                )
              ],
            )
          );
        }
      ),
    );
  }
}
