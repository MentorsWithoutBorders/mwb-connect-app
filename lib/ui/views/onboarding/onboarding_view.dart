import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/slide_swipe_widget.dart';
import 'package:mwb_connect_app/ui/views/login_signup_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key key, this.loginCallback})
    : super(key: key);    

  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final PageController _controller = PageController(viewportFraction: 0.85, keepPage: true);  
  Directory _appDocsDir;  
  List<String> _sections = [];
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _sendScreenNameAnalytics();
    _setAppDirectory();
    _setSections();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }   

  void _sendScreenNameAnalytics() {
    _analyticsService.sendScreenName('Onboarding');   
  }

  Future<void> _setAppDirectory() async {
    _appDocsDir = await getApplicationDocumentsDirectory();
    setState(() {
      _isLoaded = true;
    });    
  }    

  void _setSections() {
    _sections = AppConstants.onboarding;
  }

  Widget _showOnboarding() {
    final double sliderHeight = MediaQuery.of(context).size.height - 200;

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        verticalDirection: VerticalDirection.down,                    
        children: <Widget>[
          Expanded(
            child: SlideSwipe(
              width: double.infinity,
              height: sliderHeight,
              controller: _controller,
              slides: List.generate(
                _sections.length,
                (int itemIndex) => _buildCarouselItem(_sections[itemIndex])
              ),
            )
          ),
          Container(
            height: 150.0,
            padding: const EdgeInsets.only(top: 40.0),
            child: Column(
              children: <Widget>[
                SmoothPageIndicator(
                  controller: _controller,
                  count: _sections.length,
                  effect: const ScrollingDotsEffect(
                    spacing: 8.0,
                    dotWidth: 7.0,
                    dotHeight: 7.0,
                    dotColor: Colors.white,
                    activeDotColor: AppColors.ALLPORTS
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 35.0, 20.0, 0.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: _showLoginButton()
                        )
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: _showSignupButton()
                        )
                      )
                    ]
                  ),
                )
              ]
            )
          )
        ]
      )
    );
  }

  Widget _showLoginButton() {
    return TextButton(
      key: const Key(AppKeys.goToLoginBtn),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.white)
        )
      ),       
      onPressed: () {
        _goToLogin();
      },
      child: Text(
        'onboarding.login'.tr(), 
        style: const TextStyle(
          fontFamily: 'LatoRegular',
          color: Colors.white,
          fontSize: 15
        )
      )
    );
  }

  Widget _showSignupButton() {
    return ElevatedButton(
      key: const Key(AppKeys.goToSignupBtn),
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
        ),
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
      ), 
      onPressed: () {
        _goToSignup();
      },
      child: Text(
        'onboarding.get_started'.tr(),
        style: const TextStyle(
          fontFamily: 'LatoRegular',
          color: AppColors.ALLPORTS,
          fontSize: 15
        )
      )
    );
  }

  Widget _buildCarouselItem(String section) {
    String itemTitle = 'onboarding.$section.title'.tr();
    final String itemText = 'onboarding.$section.text'.tr();
    final List<String> itemTitleList = itemTitle.split(' ');
    final String itemTitleLastWord = itemTitleList[itemTitleList.length - 1];
    itemTitle = itemTitle.replaceAll(itemTitleLastWord, '');

    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            margin: const EdgeInsets.only(top: 100.0),
            padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 20.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: const Divider(
                    color: AppColors.BOTTICELLI
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'RopaSans',
                        color: AppColors.ALLPORTS,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: itemTitle.toUpperCase()
                        ),
                        TextSpan(
                          text: itemTitleLastWord.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.MONZA
                          )
                        )
                      ],
                    )
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),          
                  child: Text(
                    itemText,
                    style: const TextStyle(
                      fontFamily: 'LatoRegular',
                      color: AppColors.ALLPORTS,
                      fontSize: 14,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center
                  )
                )
              ]
            ),
          ),
          Container (
            height: 180.0,
            padding: const EdgeInsets.only(top: 20.0),
            child: _showImage(section),
          )
        ],
      ),
    );
  }

  Widget _showImage(String section) {
    final File fileDocsDir = _fileFromDocsDir('images/' + section + '.png');
    if (fileDocsDir.existsSync()) {
      return Image.file(fileDocsDir);
    } else {
      return Image.asset('assets/images/' + section + '.png');
    }
  }

  File _fileFromDocsDir(String filename) {
    final String pathName = p.join(_appDocsDir.path, filename);
    return File(pathName);
  }

  void _goToLogin() {
    //Phoenix.rebirth(context);
    _analyticsService.sendEvent(
      eventName: 'Go to Login'
    );
    _resetController();
    Navigator.push(context, MaterialPageRoute<LoginSignupView>(builder: (_) => LoginSignupView(
      loginCallback: widget.loginCallback,
      isLoginForm: true
    ))); 
  }

  void _resetController() {
    _controller.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
    );
  }
  
  void _goToSignup() {
    _analyticsService.sendEvent(
      eventName: 'Go to Signup'
    );
    _resetController();
    Navigator.push(context, MaterialPageRoute<LoginSignupView>(builder: (_) => LoginSignupView(
      loginCallback: widget.loginCallback,
      isLoginForm: false
    ))); 
  }  

  @override
  Widget build(BuildContext context) {
    if (_isLoaded) {
      return Scaffold(
        body: Stack(
          children: <Widget>[
            BackgroundGradient(),
            _showOnboarding()
          ]
        )
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
