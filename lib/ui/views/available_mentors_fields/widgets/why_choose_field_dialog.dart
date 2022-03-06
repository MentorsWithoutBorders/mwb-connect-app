import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class WhyChooseFieldDialog extends StatefulWidget {
  const WhyChooseFieldDialog({Key? key, this.field})
    : super(key: key); 

  final Field? field;

  @override
  State<StatefulWidget> createState() => _WhyChooseFieldDialogState();
}

class _WhyChooseFieldDialogState extends State<WhyChooseFieldDialog> {
  AvailableMentorsViewModel? _availableMentorsProvider;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }  

  Widget _showWhyChooseFieldDialog() {
    String fieldName = widget.field?.name?.toLowerCase().replaceAll(' ', '_') as String;
    String fieldDescription = 'fields_descriptions.$fieldName'.tr();
    bool hasDescription = !fieldDescription.contains('fields_descriptions');
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 15.0),
      child: Column(
        children: <Widget>[
          _showTitle(),
          hasDescription ? _showWhyChooseFieldDescription(fieldDescription) : _showWhyChooseFieldWebView(),
          _showFindMentorButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    String fieldName = widget.field?.name?.toLowerCase() as String;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context, false);
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
              'available_mentors.why_choose_field'.tr(args: [fieldName]),
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

  Widget _showWhyChooseFieldDescription(String fieldDescription) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0, right: 5.0),
        child: Scrollbar(
          controller: _scrollController, 
          isAlwaysShown: true, 
          child: SingleChildScrollView(
            controller: _scrollController,                
            child: Padding(
              padding: const EdgeInsets.only(right: 7.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
                    child: HtmlWidget(fieldDescription)
                  ),
                  _showExtractedFrom()
                ]
              )
            )
          )
        )
      )
    );
  }

  Widget _showExtractedFrom() {
    String whyChooseUrl = _availableMentorsProvider?.getWhyChooseUrl(widget.field?.id as String) as String;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              color: AppColors.DOVE_GRAY,
              fontSize: 11.0
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'available_mentors.extracted_from'.tr(),
              ),
              TextSpan(
                text: whyChooseUrl,
                style: const TextStyle(
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline
                ),
                recognizer: TapGestureRecognizer()..onTap = () async {
                  if (await canLaunch(whyChooseUrl))
                    await launch(whyChooseUrl);
                  else 
                    throw "Could not launch $whyChooseUrl";
                }
              )
            ]
          )
        ),
      ),
    );
  }

  Widget _showWhyChooseFieldWebView() {
    String? whyChooseUrl = _availableMentorsProvider?.getWhyChooseUrl(widget.field?.id as String);
    if (whyChooseUrl != null) {
      return Expanded(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(whyChooseUrl)
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
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _showFindMentorButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: AppColors.JAPANESE_LAUREL,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          padding: const EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0),
        ),
        child: Text(
          'connect_with_mentor.find_mentor'.tr(),
          style: const TextStyle(color: Colors.white)
        ),
        onPressed: () async {
          await _setField();
          Navigator.pop(context, true);
        }
      )
    );
  }  

  Future<void> _setField() async {
    _availableMentorsProvider?.setField(widget.field as Field);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _availableMentorsProvider?.addSubfield();    
  }

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return _showWhyChooseFieldDialog();
  }
}