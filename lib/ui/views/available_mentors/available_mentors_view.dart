import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors_filters/available_mentors_filters_view.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/available_mentor_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';

class AvailableMentorsView extends StatefulWidget {
  const AvailableMentorsView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _AvailableMentorsViewState();
}

class _AvailableMentorsViewState extends State<AvailableMentorsView> {
  AvailableMentorsViewModel? _availableMentorsProvider;
  bool _isAvailableMentorsRetrieved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) {
    _availableMentorsProvider?.setAvailabilityOptionId(null);
    _availableMentorsProvider?.setSubfieldOptionId(null);
    _availableMentorsProvider?.setErrorMessage('');
  }  

  Widget _showAvailableMentors() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
      child: ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          _showMentorsCards()
        ]
      )
    );
  }

  Widget _showMentorsCards() {
    List<User> mentors = _availableMentorsProvider?.availableMentors as List<User>;
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: mentors.length,
      itemBuilder: (context, index) {
        return AvailableMentor(mentor: mentors[index]);
      }
    );
  }

  Widget _showTitle() {
    return Center(
      child: Text('available_mentors.title'.tr()),
    );
  }
  
  Widget _showContent() {
    if (_isAvailableMentorsRetrieved) {
      return _showAvailableMentors();
    } else {
      return const Loader();
    }
  }

  void _goToFilters() {
    Navigator.push(context, MaterialPageRoute<AvailableMentorsFiltersView>(builder: (_) => AvailableMentorsFiltersView()));
  }  

  Future<void> _getAvailableMentors() async {
    if (!_isAvailableMentorsRetrieved && _availableMentorsProvider != null) {
      await Future.wait([
        _availableMentorsProvider!.getAvailableMentors(),
        _availableMentorsProvider!.getFieldsGoals()
      ]);      
      _isAvailableMentorsRetrieved = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return FutureBuilder<void>(
      future: _getAvailableMentors(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return Stack(
          children: <Widget>[
            const BackgroundGradient(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: _showTitle(),
                backgroundColor: Colors.transparent,          
                elevation: 0.0,
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        _goToFilters();
                      },
                      child: Icon(
                        Icons.filter_list,
                        size: 26.0
                      )
                    )
                  )
                ]
              ),
              extendBodyBehindAppBar: true,
              body: _showContent()
            )
          ],
        );
      }
    );
  }
}
