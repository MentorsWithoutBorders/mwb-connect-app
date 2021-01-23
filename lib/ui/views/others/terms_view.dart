import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class TermsView extends StatefulWidget {
  TermsView({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> with SingleTickerProviderStateMixin {
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();
  ScrollController _controller = ScrollController();
  GlobalKey _cardKey = GlobalKey();
  GlobalKey _textKey = GlobalKey();
  final double _scrollThumbMinHeight = 20.0;
  double _scrollThumbHeight = 0;    

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout); 
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }  

  _afterLayout(_) {
    final RenderBox textBox = _textKey.currentContext.findRenderObject();
    final RenderBox cardBox = _cardKey.currentContext.findRenderObject();
    double height = cardBox.size.height / textBox.size.height * 100;
    if (height < _scrollThumbMinHeight) height = _scrollThumbMinHeight;
    setState(() {
      _scrollThumbHeight = height;
    });
  }   

  Widget _showTerms(BuildContext context) {
    String termsTitle = _translator.getText('terms.text_title');
    String termsLastUpdatedLabel = _translator.getText('terms.last_updated_label');
    String termsLastUpdated = _translator.getText('terms.last_updated');
    String termsText = _translator.getText('terms.text');
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(20.0, 100.0, 20.0, 30.0),      
      child: Card(
        key: _cardKey,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 5.0, 20.0),
          child: DraggableScrollbar(
            controller: _controller,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 0.0),
              controller: _controller,
              itemCount: 1,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  key: _textKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        termsTitle,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: AppColors.ALLPORTS
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          termsLastUpdatedLabel + ' ' + termsLastUpdated,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          termsText,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 14.0
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            heightScrollThumb: _scrollThumbHeight,
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
        )
      )
    );
  }     

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(_translator.getText('terms.title')),
      )
    );
  } 

  @override
  Widget build(BuildContext context) {
    _localizationDelegate = LocalizedApp.of(context).delegate;
    _translator.localizationDelegate = _localizationDelegate;       

    return Stack(
      children: <Widget>[
        BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: _showTitle(),
            backgroundColor: Colors.transparent,          
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(null),
            )
          ),
          extendBodyBehindAppBar: true,
          body: _showTerms(context)
        )
      ],
    );
  }
}
