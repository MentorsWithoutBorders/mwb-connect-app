import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class WebView extends StatefulWidget {
  const WebView({Key? key, this.url})
    : super(key: key); 

  final String? url;

  @override
  State<StatefulWidget> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  bool _isLoading = true;

  Widget _showWebViewDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showWebView(),
          _showCloseButton()
        ]
      )
    );
  }

  Widget _showWebView() {
    if (widget.url != null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(widget.url as String)
              ),
              onLoadStop: (controller, url) async {
                setState(() {
                  _isLoading = false;
                });
              }         
            ),
            if (_isLoading) Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Loader(
                color: AppColors.ALLPORTS
              )
            )
          ]
        )
      );
    }
    return SizedBox.shrink();
  }

  Widget _showCloseButton() {
    return Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColors.BERMUDA_GRAY,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0)
          ), 
          onPressed: () async {
            Navigator.pop(context, false);
          },
          child: Text(
            'common.close'.tr(),
            style: const TextStyle(color: Colors.white)
          )
        )
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return _showWebViewDialog();
  }
}