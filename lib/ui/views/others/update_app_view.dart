import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class UpdateAppView extends StatefulWidget {
  const UpdateAppView({Key? key, this.isForced})
    : super(key: key); 

  final bool? isForced;

  @override
  State<StatefulWidget> createState() => _UpdateAppViewState();
}

class _UpdateAppViewState extends State<UpdateAppView> with WidgetsBindingObserver {
  Directory? _appDocsDir;  
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setAppDirectory();
  }

  Future<void> _setAppDirectory() async {
    _appDocsDir = await getApplicationDocumentsDirectory();
    setState(() {
      _isLoaded = true;
    });    
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }   


  Widget _showUpdateApp(BuildContext context) {
    final String updateTitle = 'update_app.title'.tr();
    final String updateText = 'update_app.text'.tr();

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
                    style: const TextStyle(
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
                    style: const TextStyle(
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
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.MONZA,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                    ),
                    padding: const EdgeInsets.fromLTRB(40.0, 12.0, 40.0, 12.0),
                  ), 
                  onPressed: () async {
                    await _updateApp();
                  },
                  child: Text(
                    'update_app.update_now'.tr(), 
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white
                    )
                  )
                ),
                if (widget.isForced == false) Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: InkWell(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(                      
                        child: Text(
                          'update_app.later'.tr(), 
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
    final File fileDocsDir = _fileFromDocsDir('images/update_app.png');
    if (fileDocsDir.existsSync()) {
      return Image.file(fileDocsDir);
    } else {
      return Image.asset('assets/images/update_app.png');
    }
  }

  File _fileFromDocsDir(String filename) {
    final String pathName = p.join(_appDocsDir?.path as String, filename);
    return File(pathName);
  }

  Future<void> _updateApp() async {
    final TargetPlatform platform = Theme.of(context).platform;
    String url = '';
    if (platform == TargetPlatform.iOS) {
      url = 'https://apps.apple.com/us/app/mwb-connect/id1582502052';
    } else if (platform == TargetPlatform.android) {
      url = 'https://play.google.com/store/apps/details?id=com.mwbconnect.app';
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }      
  }

  Future<bool> _onWillPop() async {
    if (widget.isForced == false) {
      Navigator.of(context).pop(null);
    }
    return Future<bool>.value(false);
  }  

  Widget _showLeftIcon() {
    if (widget.isForced == false) {
      return IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(null),
      );
    } else {
      return const SizedBox.shrink();
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
