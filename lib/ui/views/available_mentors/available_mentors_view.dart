import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors_filters/available_mentors_filters_view.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/available_mentor_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class AvailableMentorsView extends StatefulWidget {
  const AvailableMentorsView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _AvailableMentorsViewState();
}

class _AvailableMentorsViewState extends State<AvailableMentorsView> {
  AvailableMentorsViewModel? _availableMentorsProvider;
  bool _isFirstLoad = true;

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

  Widget _showAvailableMentors({bool isLoading = false}) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    List<User> mentors = _availableMentorsProvider?.availableMentors as List<User>;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
      child: InViewNotifierList(
        padding: const EdgeInsets.all(0),
        isInViewPortCondition:
            (double deltaTop, double deltaBottom, double vpHeight) {
          return deltaTop < (0.5 * vpHeight) && deltaBottom > (0.5 * vpHeight);
        },
        itemCount: mentors.length + 1,
        builder: (BuildContext context, int index) {
          return InViewNotifierWidget(
            id: '$index',
            builder: (BuildContext context, bool isInView, Widget? child) {
              if (isInView && index == mentors.length - 2) {
                _getMoreAvailableMentors();
              }
              if (index == mentors.length) {
                if (isLoading) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Loader(),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }
              return AvailableMentor(mentor: mentors[index]);
            }
          );
        },
      )
    );
  }

  void _getMoreAvailableMentors() {
    _availableMentorsProvider?.pageNumber++;
    _availableMentorsProvider?.getAvailableMentors();
  }  

  Widget _showTitle() {
    return Center(
      child: Text('available_mentors.title'.tr()),
    );
  }
  
  Widget _showContent() {
    bool isAvailableMentorsRetrieved = _availableMentorsProvider?.isAvailableMentorsRetrieved as bool;
    int pageNumber = _availableMentorsProvider?.pageNumber as int;
    if (isAvailableMentorsRetrieved) {
      return _showAvailableMentors(isLoading: false);
    } else {
      if (pageNumber == 1) {
        return const Loader();
      } else {
        return _showAvailableMentors(isLoading: true);
      }
    }
  }

  void _goToFilters() {
    Navigator.push(context, MaterialPageRoute<AvailableMentorsFiltersView>(builder: (_) => AvailableMentorsFiltersView()));
  }  

  Future<void> _getAvailableMentors() async {
    bool isAvailableMentorsRetrieved = _availableMentorsProvider?.isAvailableMentorsRetrieved as bool;
    if (isAvailableMentorsRetrieved == false && _availableMentorsProvider != null) {
      if (_isFirstLoad) {
        await Future.wait([
          _availableMentorsProvider!.getAvailableMentors(),
          _availableMentorsProvider!.getFieldsGoals(),
          _availableMentorsProvider!.getFields()
        ]);
        _isFirstLoad = false;
      } else {
        await Future.wait([
          _availableMentorsProvider!.getAvailableMentors()
        ]);        
      }
      _availableMentorsProvider?.isAvailableMentorsRetrieved = true;
    }
  }

  Future<bool> _resetValues(BuildContext context) async {
    _availableMentorsProvider?.resetValues();
    return true;
  }   

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return FutureBuilder<void>(
      future: _getAvailableMentors(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return WillPopScope(
          onWillPop: () => _resetValues(context),
          child: Stack(
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
          )
        );
      }
    );
  }
}
