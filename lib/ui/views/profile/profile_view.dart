import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/name_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfields_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class ProfileView extends StatefulWidget {
  ProfileView({@required this.isMentor});

  final bool isMentor;
  
  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  ProfileViewModel _profileProvider;

  void _unfocus() {
    FocusScope.of(context).unfocus();    
  }

  Widget _showProfileCard(BuildContext context, Profile profile) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 90.0, 15.0, 50.0), 
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), 
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              Name(user: profile.user),
              FieldDropdown(fields: profile.fields, selectedField: profile.user.field, onFieldTappedCallback: _unfocus),
              Subfields()
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
        child: Text(_translator.getText('profile.title'),),
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
    User user = await _profileProvider.getUserDetails();
    List<Field> fields = await _profileProvider.getFields();
    return Profile(user: user, fields: fields);
  }  

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;    
    _profileProvider = Provider.of<ProfileViewModel>(context);

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
