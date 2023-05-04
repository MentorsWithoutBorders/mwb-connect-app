import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class AcceptMentorPartnershipRequestDialog extends StatefulWidget {
  const AcceptMentorPartnershipRequestDialog({Key? key, @required this.previousMeetingUrl, @required this.onAccept, @required this.shouldUnfocus, @required this.setShouldUnfocus})
    : super(key: key);
    
  final String? previousMeetingUrl;
  final Function(String?)? onAccept;
  final bool? shouldUnfocus;
  final Function(bool)? setShouldUnfocus;

  @override
  State<StatefulWidget> createState() => _AcceptMentorPartnershipRequestDialogState();
}

class _AcceptMentorPartnershipRequestDialogState extends State<AcceptMentorPartnershipRequestDialog> {
  String urlType = AppConstants.meetingUrlType;
  String _meetingUrl = '';
  bool _shouldShowError = false;
  bool _isAccepting = false;

  @override
  void initState() {
    _meetingUrl = widget.previousMeetingUrl ?? '';
    super.initState();
  }

  Widget _showAcceptMentorPartnershipRequestDialog() {
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
          'mentor_course.accept_mentor_partnership_request'.tr(),
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
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'mentor_course.accept_mentor_partnership_request_text'.tr(),
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.DOVE_GRAY
              )
            ),
          ),
          Text(
            'mentor_course.paste_partnership_url'.tr(),
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 13.0,
              color: AppColors.DOVE_GRAY
            )
          )
        ]
      )
    );
  }

  Widget _showInput() {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InputBox(
              autofocus: true, 
              hint: '',
              text: _meetingUrl,
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
        'common.set_url_error'.tr(args: [urlType]),
        style: const TextStyle(
          fontSize: 13.0,
          color: Colors.red
        )
      ),
    );
  }

  void _changeUrl(String url) {
    setState(() {
      _meetingUrl = url;
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
            _closeDialog();
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
          child: !_isAccepting ? Text(
            'common.accept'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 40.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _acceptMentorPartnershipRequest();
          }
        )
      ]
    );
  } 

  void _closeDialog() {
    Navigator.pop(context);
  }

  Future<void> _acceptMentorPartnershipRequest() async {
    _changeUrl(Utils.setUrl(_meetingUrl));
    if (Utils.checkValidMeetingUrl(_meetingUrl) == false) {
      _setShouldShowError(true);
      return ;
    }
    _setIsAccepting(true);
    await widget.onAccept!(_meetingUrl);
    Navigator.pop(context);
  }
  
  void _setIsAccepting(bool isAccepting) {
    setState(() {
      _isAccepting = isAccepting;
    });  
  }

  void _afterLayout(_) {
    if (widget.shouldUnfocus == true) {
      _unfocus();
      widget.setShouldUnfocus!(false);
    }  
  }
  
  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  Future<bool> _onWillPop() async {
    _closeDialog();
    return true;
  }    
  
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _unfocus();
        },
        child: _showAcceptMentorPartnershipRequestDialog()
      ),
    );
  }
}