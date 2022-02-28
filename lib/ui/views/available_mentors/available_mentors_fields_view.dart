import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class AvailableMentorsFieldsView extends StatefulWidget {
  const AvailableMentorsFieldsView({Key? key})
    : super(key: key);   

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
        padding: const EdgeInsets.only(top: 10.0),
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      child: Wrap(
        children: [
          Center(
            child: Container(
              width: width * 0.9,
              height: height * 0.87,
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
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
          Container(
            height: 32.0,
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: Center(
              child: Text(
                field.name as String,
                textAlign: TextAlign.center
              )
            )
          )
        ]
      )
    );
  }

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text('available_mentors.title'.tr()),
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
      await _availableMentorsProvider?.getFields();      
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
                  elevation: 0.0
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
