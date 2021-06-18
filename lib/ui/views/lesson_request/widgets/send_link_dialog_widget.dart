import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class SendLinkDialog extends StatefulWidget {
  const SendLinkDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _SendLinkDialogState();
}

class _SendLinkDialogState extends State<SendLinkDialog> {
  LessonRequestViewModel _lessonRequestProvider;
  String _link = '';
  bool _isAcceptingLessonRequest = false;

  Widget _showSendLinkDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showInput(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    String appName = 'Google Meet/Zoom';
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Center(
        child: Text(
          'lesson_request.send_link'.tr(args: [appName]),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0, bottom: 8.0),
      child: Text(
        'lesson_request.paste_link'.tr(),
        style: const TextStyle(
          fontSize: 13.0,
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  Widget _showInput() {
    return Container(
      padding: EdgeInsets.only(bottom: 15.0),
      child: InputBox(
        autofocus: false, 
        hint: '',
        text: _link, 
        inputChangedCallback: _changeLink
      )
    ); 
  }

  void _changeLink(String link) {
    setState(() {
      _link = link;
    });
  }
  
  Widget _showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
            child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          child: !_isAcceptingLessonRequest ? Text(
            'common.send'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 40.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _acceptLessonRequest();
            Navigator.pop(context);
          }
        )
      ]
    );
  } 

  Future<void> _acceptLessonRequest() async {  
    _setIsAcceptingLessonRequest(true);
    await _lessonRequestProvider.acceptLessonRequest(_link);
  }
  
  void _setIsAcceptingLessonRequest(bool isAccepting) {
    setState(() {
      _isAcceptingLessonRequest = isAccepting;
    });  
  }    
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showSendLinkDialog();
  }
}