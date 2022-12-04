import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class AcceptMentorPartnershipRequestDialog extends StatefulWidget {
  const AcceptMentorPartnershipRequestDialog({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _AcceptMentorPartnershipRequestDialogState();
}

class _AcceptMentorPartnershipRequestDialogState extends State<AcceptMentorPartnershipRequestDialog> {
  MentorCourseViewModel? _mentorCourseProvider;
  String urlType = AppConstants.meetingUrlType;
  String _url = '';
  bool _shouldShowError = false;
  bool _isAcceptingMentorPartnershipRequest = false;

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
          'common.set_url'.tr(args: [urlType]),
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
              text: _url,
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
            _closeDialog();
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
          child: !_isAcceptingMentorPartnershipRequest ? Text(
            'common.set'.tr(),
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
    _changeUrl(Utils.setUrl(_url));
    if (_mentorCourseProvider?.checkValidUrl(_url) == false) {
      _setShouldShowError(true);
      return ;
    }
    _setIsAcceptingMentorPartnershipRequest(true);
    await _mentorCourseProvider?.acceptMentorPartnershipRequest(_url);
    Navigator.pop(context);
  }
  
  void _setIsAcceptingMentorPartnershipRequest(bool isAccepting) {
    setState(() {
      _isAcceptingMentorPartnershipRequest = isAccepting;
    });  
  }

  void _afterLayout(_) {
    if (_mentorCourseProvider?.shouldUnfocus == true) {
      _unfocus();
      _mentorCourseProvider?.shouldUnfocus = false;
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
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);

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