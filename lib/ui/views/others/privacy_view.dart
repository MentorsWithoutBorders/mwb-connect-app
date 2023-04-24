import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class PrivacyView extends StatefulWidget {
  const PrivacyView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _PrivacyViewState();
}

class _PrivacyViewState extends State<PrivacyView> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _textKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }  

  Widget _showPrivacy() {
    final String privacyLastUpdatedLabel = 'privacy.last_updated_label'.tr();
    final String privacyLastUpdated = 'privacy.last_updated'.tr();
    final String privacyText = 'privacy.text'.tr();
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 30.0),      
      child: Card(
        key: _cardKey,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 7.0, 20.0),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 0.0),
              controller: _scrollController,
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
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
                    ]
                  )
                );
              }
            )
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
        const BackgroundGradient(),
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
          body: _showPrivacy()
        )
      ],
    );
  }
}
