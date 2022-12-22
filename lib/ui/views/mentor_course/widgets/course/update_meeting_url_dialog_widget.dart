import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class UpdateMeetingUrlDialog extends StatefulWidget {
  const UpdateMeetingUrlDialog({Key? key, this.meetingUrl, this.onUpdate})
    : super(key: key);  

  final String? meetingUrl;
  final Function(String)? onUpdate;

  @override
  State<StatefulWidget> createState() => _UpdateMeetingUrlDialogState();
}

class _UpdateMeetingUrlDialogState extends State<UpdateMeetingUrlDialog> {
  String urlType = AppConstants.meetingUrlType;
  String? _url;
  bool _shouldShowError = false;
  bool _isUpdatingMeetingUrl = false;

  Widget _showUpdateMeetingUrlDialog() {
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
              text: widget.meetingUrl,
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
            primary: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          child: !_isUpdatingMeetingUrl ? Text(
            'common.update'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 45.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _updateMeetingUrl();
          }
        )
      ]
    );
  } 

  Future<void> _updateMeetingUrl() async {
    String meetingUrl = _url ?? '';
    if (Utils.checkValidUrl(meetingUrl) == false) {
      _setShouldShowError(true);
      return ;
    }    
    _setIsUpdatingMeetingUrl(true);
    await widget.onUpdate!(meetingUrl);
    Navigator.pop(context);
  }
  
  void _setIsUpdatingMeetingUrl(bool isUpdating) {
    setState(() {
      _isUpdatingMeetingUrl = isUpdating;
    });  
  }    
  
  @override
  Widget build(BuildContext context) {
    return _showUpdateMeetingUrlDialog();
  }
}