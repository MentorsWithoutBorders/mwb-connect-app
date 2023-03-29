import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class ChangeUrlDialog extends StatefulWidget {
  const ChangeUrlDialog({Key? key, this.url})
    : super(key: key);  

  final String? url;

  @override
  State<StatefulWidget> createState() => _ChangeUrlDialogState();
}

class _ChangeUrlDialogState extends State<ChangeUrlDialog> {
  LessonRequestViewModel? _lessonRequestProvider;
  String urlType = AppConstants.meetingUrlType;  
  String? _url;
  bool _shouldShowError = false;
  bool _isUpdatingLessonUrl = false;

  @override
  void initState() {
    super.initState();
    _url = widget.url != null ? widget.url : '';
  }  

  Widget _showChangeUrlDialog() {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Center(
        child: Text(
          'common.update_url'.tr(args: [urlType]),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
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
        'common.paste_url'.tr(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InputBox(
              autofocus: true, 
              hint: '',
              text: _url as String,
              textCapitalization: TextCapitalization.none, 
              inputChangedCallback: _changeUrl
            ),
          ),
          if (_shouldShowError) _showError()
        ],
      )
    ); 
  }

  Widget _showError() {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Text(
        'common.send_url_error'.tr(args: [urlType]),
        style: const TextStyle(
          fontSize: 12.0,
          color: Colors.red
        )
      ),
    );
  }  

  void _changeUrl(String url) {
    setState(() {
      _url = url;
    });
    _setShouldShowError(false);    
  }

  void _setShouldShowError(bool showError) {
    setState(() {
      _shouldShowError = showError;
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
            backgroundColor: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          child: !_isUpdatingLessonUrl ? Text(
            'common.update'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 40.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _changeLessonUrl();
          }
        )
      ]
    );
  } 

  Future<void> _changeLessonUrl() async {
    if (_lessonRequestProvider?.checkValidMeetingUrl(_url as String) == false) {
      _setShouldShowError(true);
      return ;
    }    
    _setIsUpdatingLessonUrl(true);
    await _lessonRequestProvider?.changeLessonUrl(_url as String);
    Navigator.pop(context);
  }
  
  void _setIsUpdatingLessonUrl(bool isUpdating) {
    setState(() {
      _isUpdatingLessonUrl = isUpdating;
    });  
  }    
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showChangeUrlDialog();
  }
}