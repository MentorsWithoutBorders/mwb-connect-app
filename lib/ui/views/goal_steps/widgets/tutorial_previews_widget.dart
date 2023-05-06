import 'dart:math' as math; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/views/tutorials/tutorial_view.dart';

class TutorialPreviews extends StatefulWidget {
  const TutorialPreviews({Key? key})
    : super(key: key);  
  
  @override
  State<StatefulWidget> createState() => _TutorialPreviewsState();
}

class _TutorialPreviewsState extends State<TutorialPreviews> with TickerProviderStateMixin {
  StepsViewModel? _stepsProvider;
  final PageController _pageController = PageController(viewportFraction: 1, keepPage: true);
  AnimationController? _animationController;
  Animation<double>? _animation;
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _pageIndicatorKey = GlobalKey();
  final int _animationDuration = 300;
  double _textHeight = 0;
  double _pageIndicatorHeight = 0;
  double _previewsOpenHeight = 0;
  final double _previewsClosedHeight = 30;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    _setAnimationController();
  }

  void _setAnimationController() { 
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: _animationDuration));
    _animation = Tween<double>(begin: _previewsClosedHeight, end: _previewsOpenHeight).animate(_animationController as AnimationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _stepsProvider?.setIsTutorialPreviewsAnimationCompleted(true);
          if (_stepsProvider?.shouldShowTutorialChevrons == false) {
            _stepsProvider?.setShouldShowTutorialChevrons(false);
          } else {
            _stepsProvider?.setShouldShowTutorialChevrons(true);
          }
        }
      });
    _animationController?.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController?.dispose();
    super.dispose();
  }  

  void _afterLayout(_) {
    final RenderBox textBox = _stackKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox pageIndicatorBox = _pageIndicatorKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      _textHeight = textBox.size.height;
      _pageIndicatorHeight = pageIndicatorBox.size.height + 2;
      _previewsOpenHeight = _textHeight + _pageIndicatorHeight;
      _isOpen = true;
    });
    _setAnimationController();         
  } 

  Widget _showTutorialPreviews(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      height: _animation?.value,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          _showPreviewsOpen(),
          _showPreviewsClosed()
        ]
      )
    );
  }

  Widget _showPreviewsOpen() {
    final LocalStorageService _storageService = locator<LocalStorageService>();
    final List<String> previews = [];
    final Map<String, dynamic> tutorials = _storageService.tutorials;
    tutorials.forEach((String key, dynamic value) => previews.add(key));

    return AnimatedOpacity(
      opacity: _isOpen ? 1.0 : 0.0,
      duration: Duration(milliseconds: _animationDuration),
      child: Wrap(
        children: <Widget>[
          _buildTextStack(context, previews),
          Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => {
                  _closePreviews()
                },
                child: Container(
                  width: 58,
                  child: _showChevron(isUp: true)
                )
              ),
              Expanded(
                child: Center(
                  child: Container(
                    key: _pageIndicatorKey,
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: previews.length,
                      effect: const ScrollingDotsEffect(
                        spacing: 8.0,
                        dotWidth: 7.0,
                        dotHeight: 7.0,
                        dotColor: AppColors.SILVER,
                        activeDotColor: Colors.yellowAccent
                      ),
                    ),
                  )
                )
              ),
              GestureDetector(
                onTap: () => {
                  _closePreviews()
                },
                child: Container(
                  width: 58,
                  child: _showChevron(isUp: true)
                )
              ),
            ]
          )
        ]
      )
    );
  }

  Widget _showChevron({bool? isUp}) {
    return AnimatedOpacity(
      opacity: _stepsProvider?.shouldShowTutorialChevrons == true ? 1.0 : 0.0,
      duration: Duration(milliseconds: _animationDuration),
      child: Transform(
        alignment: Alignment.center,
        transform: isUp == false ? Matrix4.rotationX(math.pi) : Matrix4.rotationY(math.pi),
        child: Image.asset(
          'assets/images/chevron.png',
          width: 18,
          height: 18,
        )
      ),
    );
  }

  void _closePreviews() {
    setState(() {
      _isOpen = false;
    });
    _stepsProvider?.setIsTutorialPreviewsAnimationCompleted(false);
    _animationController?.reverse();
  }  

  Widget _showPreviewsClosed() {
    return AnimatedOpacity(
      opacity: _isOpen ? 0.0 : 1.0,
      duration: Duration(milliseconds: _animationDuration),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => {
              _openPreviews()
            },
            child: Container(
              width: 58,
              child: _showChevron(isUp: false)
            )
          ),
          Expanded(
            child: AnimatedOpacity(
              opacity: _stepsProvider?.shouldShowTutorialChevrons == true ? 1.0 : 0.0,
              duration: Duration(milliseconds: _animationDuration),              
              child: Center(
                child: GestureDetector(
                  onTap: () => {
                    _openPreviews()
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'tutorial_previews.show_helpers'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold
                      )
                    )
                  )
                ),
              ),
            )
          ),
          GestureDetector(
            onTap: () => {
              _openPreviews()
            },
            child: Container(
              width: 58,
              child: _showChevron(isUp: false)
            )
          )
        ]
      )
    ); 
  }

  void _openPreviews() {
    setState(() {
      _isOpen = true;
    });    
    _stepsProvider?.setIsTutorialPreviewsAnimationCompleted(false);
    _animationController?.forward();
  }

  Widget _buildTextStack(BuildContext context, List<String> previews) {
    Widget carousel;
    carousel = Container(
      height: _textHeight,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (BuildContext context, int itemIndex) {
          return _buildCarouselItem(context, previews[itemIndex]);
        },
        itemCount: previews.length,
      ),
    );

    final List<Column> previewItems = previews
      .map((String item) => Column(children: [
        Container(
          child: _buildCarouselItem(context, item)
        )]))
      .toList();

    return IndexedStack(
      key: _stackKey,
      children: <Widget>[
        carousel,
        ...previewItems
      ],
    );
  }   

  Widget _buildCarouselItem(BuildContext context, String item) {
    final String itemText = 'tutorials.$item.preview.text'.tr();
    final String itemLink = 'tutorials.$item.preview.link'.tr();
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12.0,
            color: Colors.white,
            height: 1.2
          ),
          children: <TextSpan>[
            TextSpan(
              text: itemText + ' ',
              recognizer: TapGestureRecognizer()..onTap = () {
                if (_isOpen) {
                  Navigator.push(context, MaterialPageRoute<TutorialView>(builder: (_) => TutorialView(type: item)));
                }
              },              
            ),
            TextSpan(
              text: itemLink,
              style: const TextStyle(
                color: Colors.yellow,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.bold
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                if (_isOpen) {
                  Navigator.push(context, MaterialPageRoute<TutorialView>(builder: (_) => TutorialView(type: item)));
                }
              },
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {  
    _stepsProvider = Provider.of<StepsViewModel>(context);

    return _showTutorialPreviews(context);
  }
}
