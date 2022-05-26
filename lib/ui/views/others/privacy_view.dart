import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class PrivacyView extends StatefulWidget {
  const PrivacyView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _PrivacyViewState();
}

class _PrivacyViewState extends State<PrivacyView> with SingleTickerProviderStateMixin {
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
    final RenderBox textBox = _textKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox cardBox = _cardKey.currentContext?.findRenderObject() as RenderBox;
    double height = cardBox.size.height / textBox.size.height * 100;
    if (height < _scrollThumbMinHeight) height = _scrollThumbMinHeight;
    setState(() {
      _scrollThumbHeight = height;
    });
  }   

  Widget _showPrivacy() {
    final String privacyLastUpdatedLabel = 'privacy.last_updated_label'.tr();
    final String privacyLastUpdated = 'privacy.last_updated'.tr();
    final String privacyText = 'privacy.text'.tr();
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          privacyLastUpdatedLabel + ' ' + privacyLastUpdated,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                        child: HtmlWidget(privacyText)
                      )
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
              Text? labelText,
              BoxConstraints? labelConstraints
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
        child: Text(
          'privacy.title'.tr(),
          textAlign: TextAlign.center
        )
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
          body: _showPrivacy()
        )
      ],
    );
  }
}
