import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class TermsView extends StatefulWidget {
  const TermsView({Key key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _TermsViewState();
}

class _TermsViewState extends State<TermsView> with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _textKey = GlobalKey();
  final double _scrollThumbMinHeight = 20.0;
  double _scrollThumbHeight = 0;    

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout); 
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }  

  void _afterLayout(_) {
    final RenderBox textBox = _textKey.currentContext.findRenderObject();
    final RenderBox cardBox = _cardKey.currentContext.findRenderObject();
    double height = cardBox.size.height / textBox.size.height * 100;
    if (height < _scrollThumbMinHeight) height = _scrollThumbMinHeight;
    setState(() {
      _scrollThumbHeight = height;
    });
  }   

  Widget _showTerms() {
    final String termsTitle = 'terms.text_title'.tr();
    final String termsLastUpdatedLabel = 'terms.last_updated_label'.tr();
    final String termsLastUpdated = 'terms.last_updated'.tr();
    final String termsText = 'terms.text'.tr();
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(20.0, statusBarHeight + 60.0, 20.0, 30.0),      
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
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  key: _textKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        termsTitle,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: AppColors.ALLPORTS
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          termsLastUpdatedLabel + ' ' + termsLastUpdated,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
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
                          style: const TextStyle(
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
        child: Text('terms.title'.tr()),
      )
    );
  } 

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(null),
            )
          ),
          extendBodyBehindAppBar: true,
          body: _showTerms()
        )
      ],
    );
  }
}
