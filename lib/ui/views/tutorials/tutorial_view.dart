import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class TutorialView extends StatefulWidget {
  const TutorialView({Key? key, @required this.type, this.section})
    : super(key: key); 

  final String? type;
  final String? section;
  
  @override
  State<StatefulWidget> createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  final ScrollController _scrollController = ScrollController();
  final double _pageIndicatorHeight = 30.0;
  Directory? _appDocsDir;  
  final Map<String, bool> _imageExists = {};
  List<String> _sections = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _setSections();
    _setImageExists();
  }

  void _setSections() {
    final LocalStorageService _storageService = locator<LocalStorageService>();
    final Map<String, List<String>> tutorials = {};
    for (final MapEntry<String, dynamic> entry in _storageService.tutorials.entries) {
      tutorials[entry.key] = entry.value.cast<String>();
    }    
    setState(() {
      _sections = tutorials[widget.type!] as List<String>;
    });
    _sections.forEach((String section) {
      _imageExists.putIfAbsent(section, () => true);
    });
  }

  Future<void> _setImageExists() async {
    await _setAppDirectory();
    await Future.forEach(_sections, (String section) async {
      final File fileDocsDir = _fileFromDocsDir('images/' + _imageName(section) + '.png');
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
    _scrollController.dispose();
    super.dispose();
  }  

  Future<void> _setAppDirectory() async {
    _appDocsDir = await getApplicationDocumentsDirectory();
  }  
  
  Widget _showTutorial() {
    final int initialPage = widget.section != null ? _sections.indexOf(widget.section!) : 0;
    final PageController controller = PageController(initialPage: initialPage, viewportFraction: 1, keepPage: true);
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 50.0),    
      child: Container(
        decoration: const BoxDecoration(
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
                  return _buildCarouselItem( _sections[itemIndex]);
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
                effect: const ScrollingDotsEffect(
                  spacing: 8.0,
                  dotWidth: 7.0,
                  dotHeight: 7.0,
                  dotColor: AppColors.SILVER,
                  activeDotColor: AppColors.EMERALD
                ),
              ),
            ),
          ]
        )
      )
    );
  }

  Widget _buildCarouselItem(String section) {
    final String itemTitle = 'tutorials.${widget.type}.$section.title'.tr();
    final String itemText = 'tutorials.${widget.type}.$section.text'.tr();

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 14.0, 20.0),
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 0.0),
          controller: _scrollController,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                if (itemTitle != '') Container(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    itemTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container (
                  height: _imageExists[section] == true ? 140 : 0,
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: _showImage(section),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 10.0),
                  child: HtmlWidget(itemText)
                )
              ]
            );
          }
        )
      )
    );
  }

  String _imageName(String section) {
    return section == 'main' ? widget.type as String : section;
  }

  Widget _showImage(String section) {
    final File fileDocsDir = _fileFromDocsDir('images/' + _imageName(section) + '.png');
    if (fileDocsDir.existsSync()) {
      return Image.file(fileDocsDir);
    } else {
      return Image.asset('assets/images/' + _imageName(section) + '.png');
    }
  }

  File _fileFromDocsDir(String filename) {
    final String pathName = p.join(_appDocsDir?.path as String, filename);
    return File(pathName);
  }

  Widget _buildWaitingScreen() {
    return Stack(
      children: const <Widget>[
        BackgroundGradient(),
        Loader()
      ]
    );
  }

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'tutorials.${widget.type}.title'.tr(),
          textAlign: TextAlign.center
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return Stack(
        children: [
          const BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: _showTitle(),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            body: Center(
              child: _showTutorial()
            ),
          )
        ]
      );
    } else {
      return _buildWaitingScreen();
    }
  }
}
