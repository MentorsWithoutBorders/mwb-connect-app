import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors_fields/widgets/why_choose_field_dialog.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/available_mentors_view.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class AvailableMentorsFieldsView extends StatefulWidget {
  const AvailableMentorsFieldsView({Key? key, this.shouldReloadCallback})
    : super(key: key);  

  final VoidCallback? shouldReloadCallback;

  @override
  State<StatefulWidget> createState() => _AvailableMentorsFieldsViewState();
}

class _AvailableMentorsFieldsViewState extends State<AvailableMentorsFieldsView> {
  AvailableMentorsViewModel? _availableMentorsProvider;
  bool _areFieldsRetrieved = false;

  Widget _showAvailableMentorsFields() {
    final List<Field> fields = _availableMentorsProvider?.fields as List<Field>;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.0, statusBarHeight + 60.0, 20.0, 0.0), 
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
        itemCount: fields.length > 0 ? fields.length - 1 : 0,
        itemBuilder: (context, index) => _showFieldItem(fields[index + 1]),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 25.0,
          crossAxisSpacing: 20.0
        ),
      )
    );
  }

  Widget _showFieldItem(Field field) {
    final double width = MediaQuery.of(context).size.width * 0.35;
    final double height = MediaQuery.of(context).size.width * 0.35;
    Map<String, String> fieldIconFilePaths = _availableMentorsProvider?.fieldIconFilePaths as Map<String, String>;
    String iconFilePath = fieldIconFilePaths[field.name] as String;
    bool isLocal = !iconFilePath.contains('firebase');
    return GestureDetector(
      onTap: () {
        _goToWhyChooseField(field);
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: width * 0.9,
                height: height * 0.85,
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                child: isLocal ? Image.asset(iconFilePath) : 
                  CachedNetworkImage(
                    imageUrl: iconFilePath,
                    placeholder: (context, url) => Center(
                      child: Loader(color: AppColors.TANGO),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error)
                  )
              )
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      field.name as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.DOVE_GRAY
                      )
                    ),
                  ],
                )
              ),
            )
          ]
        )
      ),
    );
  }

  void _goToWhyChooseField(Field field) {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: WhyChooseFieldDialog(field: field)
      )
    ).then((shouldGoToAvailableMentors) {
      if (shouldGoToAvailableMentors == true) {
        _goToAvailableMentors();
      }
    });
  }

  Future<void> _goToAvailableMentors() async {
    final shouldReload = await Navigator.push(context, MaterialPageRoute(builder: (_) => AvailableMentorsView()));  
    if (shouldReload == true) {
      widget.shouldReloadCallback!();
      Navigator.pop(context);
    }
  }  

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 55.0),
      child: Center(
        child: Text(
          'available_mentors.title'.tr(),
          textAlign: TextAlign.center
        ),
      ),
    );
  }

  Widget _showContent() {
    if (_areFieldsRetrieved) {
      return _showAvailableMentorsFields();
    } else {
      return const Loader();
    }
  }  

  Future<bool> _onWillPop(BuildContext context) async {
    _availableMentorsProvider?.resetValues();
    return true;
  }

  Future<void> _getFields() async {
    if (!_areFieldsRetrieved && _availableMentorsProvider != null) {
      await Future.wait([
        _availableMentorsProvider!.getFields(),
        _availableMentorsProvider!.getFieldsGoals()
      ]);      
      _areFieldsRetrieved = true;
    }
  }   

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: FutureBuilder<void>(
        future: _getFields(),
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
                  leading: GestureDetector(
                    onTap: () async { 
                      _onWillPop(context);
                      Navigator.pop(context);
                    },
                    child: Platform.isIOS ? Icon(
                      Icons.arrow_back_ios_new
                    ) : Icon(
                      Icons.arrow_back
                    )
                  )
                ),
                extendBodyBehindAppBar: true,
                body: _showContent()
              )
            ],
          );
        }
      ),
    );
  }
}
