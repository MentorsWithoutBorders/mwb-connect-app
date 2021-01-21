import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/name_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient.dart';
import 'package:mwb_connect_app/ui/widgets/loader.dart';

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
  User user;
  
  Widget _showProfileCard(context) {
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
          child: Name(user: user)
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
  
  Widget _showContent(BuildContext context, bool hasData) {
    if (!hasData) {
      return Loader();
    } else {
      return _showProfileCard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;    
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return FutureBuilder(
      future: _profileProvider.getUserDetails(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        user = snapshot.data;
        return Stack(
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
              body: _showContent(context, snapshot.hasData)
            )
          ],
        );
      }
    );
  }
}
