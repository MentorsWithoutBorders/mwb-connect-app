import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class UpdateAppView extends StatefulWidget {
  UpdateAppView({this.isForced});

  final bool isForced;

  @override
  State<StatefulWidget> createState() => _UpdateAppViewState();
}

class _UpdateAppViewState extends State<UpdateAppView> {
  Directory _appDocsDir;  
  bool _isLoaded = false;

  @override
  initState() {
    super.initState();
    _setAppDirectory();
  }

  _setAppDirectory() async {
    _appDocsDir = await getApplicationDocumentsDirectory();
    setState(() {
      _isLoaded = true;
    });    
  }    

  Widget _showUpdateApp(BuildContext context) {
    String updateTitle = 'update_app.title'.tr();
    String updateText = 'update_app.text'.tr();

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(15.0, 100.0, 15.0, 20.0),    
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,                    
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Container(
                  height: 180.0,
                  child: _showUpdateImage()
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    updateTitle,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    )
                  ) 
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    updateText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.white,
                      height: 1.2
                    ),
                  ) 
                )
              ],
            )
          ),
          Container(
            height: 150.0,
            padding: const EdgeInsets.only(top: 40.0),
            child: Column(
              children: <Widget>[
                RaisedButton(
                  padding: const EdgeInsets.fromLTRB(40.0, 12.0, 40.0, 12.0),
                  splashColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  onPressed: () {
                    _updateApp();
                  },
                  child: Text(
                    'Update now', 
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white
                    )
                  ),
                  color: AppColors.MONZA,
                ),
                if (!widget.isForced) Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(                      
                        child: Text(
                          'Later', 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          )
                        )
                      )
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ]
            )
          )
        ]
      )
    );
  }

  Widget _showUpdateImage() {
    File fileDocsDir = _fileFromDocsDir('images/update_app.png');
    if (fileDocsDir.existsSync()) {
      return Image.file(fileDocsDir);
    } else {
      return Image.asset('assets/images/update_app.png');
    }
  }

  File _fileFromDocsDir(String filename) {
    String pathName = p.join(_appDocsDir.path, filename);
    return File(pathName);
  }

  void _updateApp() {
    Navigator.of(context).pop(null);
  }

  Future<bool> _onWillPop() async {
    if (!widget.isForced) {
      Navigator.of(context).pop(null);
    }
  }  

  Widget _showLeftIcon() {
    if (!widget.isForced) {
      return IconButton(
        icon: Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(null),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,          
            elevation: 0.0,
            leading: _showLeftIcon()
          ),
          extendBodyBehindAppBar: true,        
          body: Stack(
            children: <Widget>[
              BackgroundGradient(),
              _showUpdateApp(context)
            ]
          )
        ),
      );
    } else {
      return Stack(
        children: <Widget>[
          BackgroundGradient(),
          Loader()
        ]
      );
    }
  }
}
