import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_translate/flutter_translate.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient.dart';
import 'package:mwb_connect_app/ui/widgets/loader.dart';

class TutorialView extends StatefulWidget {
  TutorialView({@required this.type, this.section});

  final String type;
  final String section;
  
  @override
  State<StatefulWidget> createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  ScrollController _controller = ScrollController();
  final double _pageIndicatorHeight = 30.0;
  Directory _appDocsDir;  
  Map<String, bool> _imageExists = Map();
  List<String> _sections = List();
  bool _isLoaded = false;

  @override
  initState() {
    super.initState();
    _setSections();
    _setImageExists();
  }

  _setSections() {
    LocalStorageService _storageService = locator<LocalStorageService>();
    setState(() {
      _sections = _storageService.tutorials[widget.type].split(', ');
    });
    _sections.forEach((section) {
      _imageExists.putIfAbsent(section, () => true);
    });
  }

  _setImageExists() async {
    await _setAppDirectory();
    await Future.forEach(_sections, (section) async {
      File fileDocsDir = _fileFromDocsDir('images/' + _imageName(section) + '.png');
      await rootBundle.load('assets/images/' + _imageName(section) + '.png').catchError((_) {
        if (!fileDocsDir.existsSync()) {
          _imageExists[_imageName(section)] = false;
        }
      });
    });
    setState(() {
      _isLoaded = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }  

  _setAppDirectory() async {
    _appDocsDir = await getApplicationDocumentsDirectory();
  }  
  
  Widget _showTutorial(BuildContext context, _localizationDelegate) {
    int initialPage = widget.section != null ? _sections.indexOf(widget.section) : 0;
    PageController controller = PageController(initialPage: initialPage, viewportFraction: 1, keepPage: true);
    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 90.0, 15.0, 50.0),    
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: VerticalDirection.down,                    
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return _buildCarouselItem(context, _localizationDelegate, _sections[itemIndex]);
                },
                itemCount: _sections.length
              )
            ),
            Container(
              height: _pageIndicatorHeight,
              padding: const EdgeInsets.only(bottom: 10.0),
              child: SmoothPageIndicator(
                controller: controller,
                count: _sections.length,
                effect: ScrollingDotsEffect(
                  spacing: 8.0,
                  dotWidth: 7.0,
                  dotHeight: 7.0,
                  dotColor: AppColors.SILVER,
                  activeDotColor: AppColors.MINT_GREEN
                ),
              ),
            ),
          ]
        )
      )
    );
  }

  Widget _buildCarouselItem(BuildContext context, _localizationDelegate, String section) {
    String itemTitle = _translator.getText('tutorials.${widget.type}.$section.title');
    String itemText = _translator.getText('tutorials.${widget.type}.$section.text');

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 5.0, 20.0),
      child: DraggableScrollbar(
        controller: _controller,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 0.0),
          controller: _controller,
          itemCount: 1,
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                if (itemTitle != '') Container(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    itemTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container (
                  height: _imageExists[section] ? 170 : 0,
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: _showImage(section),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 25.0, 10.0),
                  child: HtmlWidget(itemText)
                )
              ]
            );
          },
        ),
        heightScrollThumb: 300.0,
        backgroundColor: AppColors.SILVER,
        scrollThumbBuilder: (
          Color backgroundColor,
          Animation<double> thumbAnimation,
          Animation<double> labelAnimation,
          double height, {
          Text labelText,
          BoxConstraints labelConstraints
        }) {
          return FadeTransition(
            opacity: thumbAnimation,
            child: Container(
              height: height,
              width: 5.0,
              color: backgroundColor,
            ),
          );
        }
      )
    );
  }

  String _imageName(String section) {
    return section == 'main' ? widget.type : section;
  }

  Widget _showImage(String section) {
    File fileDocsDir = _fileFromDocsDir('images/' + _imageName(section) + '.png');
    if (fileDocsDir.existsSync()) {
      return Image.file(fileDocsDir);
    } else {
      return Image.asset('assets/images/' + _imageName(section) + '.png');
    }
  }

  File _fileFromDocsDir(String filename) {
    String pathName = p.join(_appDocsDir.path, filename);
    return File(pathName);
  }

  Widget _buildWaitingScreen() {
    return Stack(
      children: <Widget>[
        BackgroundGradient(),
        Loader()
      ]
    );
  }   

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;    
    _translator.localizationDelegate = _localizationDelegate;  
    
    if (_isLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.only(right: 50.0),
            child: Center(
              child: Text(_translator.getText('tutorials.${widget.type}.title')),
            )
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: <Widget>[
            BackgroundGradient(),
            _showTutorial(context, _localizationDelegate)
          ]
        )
      );
    } else {
      return _buildWaitingScreen();
    }
  }
}
