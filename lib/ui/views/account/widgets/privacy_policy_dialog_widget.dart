import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }  

  Widget _showPrivacyPolicyDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 15.0),
      child: Column(
        children: <Widget>[
          _showTitle(),
          _showPrivacyPolicy()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 25.0,
              height: 25.0,
              child: Center(
                child: Container(
                  width: 15.0,
                  height: 15.0,                  
                  child: Image.asset(
                    'assets/images/close_icon.png',
                  ),
                ),
              ),
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 18.0),
          child: Center(
            child: Text(
              'privacy.title'.tr(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 18.0,
                color: AppColors.DOVE_GRAY,
                fontWeight: FontWeight.bold,
                height: 1.3
              )
            )
          )
        )
      ]
    );
  }  

  Widget _showPrivacyPolicy() {
    final String privacyText = 'privacy.text'.tr();
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0, right: 5.0),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 10.0),
                          child: HtmlWidget(privacyText,
                            onLoadingBuilder: (context, element, loadingProgress) => Padding(
                              padding: const EdgeInsets.only(bottom: 70.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showPrivacyPolicyDialog();
  }
}