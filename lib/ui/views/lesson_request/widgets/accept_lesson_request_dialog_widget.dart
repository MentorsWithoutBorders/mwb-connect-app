import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/lesson_recurrence_widget.dart';
import 'package:mwb_connect_app/ui/widgets/input_box_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class AcceptLessonRequestDialog extends StatefulWidget {
  const AcceptLessonRequestDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _AcceptLessonRequestDialogState();
}

class _AcceptLessonRequestDialogState extends State<AcceptLessonRequestDialog> {
  LessonRequestViewModel _lessonRequestProvider;
  String urlType = AppConstants.meetingUrlType;
  String _url = '';
  bool _shouldShowError = false;
  bool _isAcceptingLessonRequest = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);
    _setInitialUrl();
    super.didChangeDependencies();
  }
  
  void _setInitialUrl() {
    if (!_isInit) {
      if (_url == '' && _lessonRequestProvider != null && _lessonRequestProvider.previousLesson != null) {
        _changeUrl(_lessonRequestProvider.previousLesson.meetingUrl);
      }   
      _isInit = true;
    }
  }

  Widget _showAcceptLessonRequestDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showInput(),
          LessonRecurrence(),
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
          'lesson_request.send_url'.tr(args: [urlType]),
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
        'lesson_request.paste_url'.tr(),
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
        'lesson_request.send_url_error'.tr(args: [urlType]),
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
            primary: AppColors.WATERCOURSE,
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
          }
        )
      ]
    );
  } 

  void _closeDialog() {
    if (_lessonRequestProvider.nextLesson.isRecurrent) {
      _lessonRequestProvider.setIsLessonRecurrent();
    }
    Navigator.pop(context);
  }

  Future<void> _acceptLessonRequest() async {
    if (!_lessonRequestProvider.checkValidUrl(_url)) {
      _setShouldShowError(true);
      return ;
    }
    _setIsAcceptingLessonRequest(true);
    await _lessonRequestProvider.acceptLessonRequest(_url, context);
    Navigator.pop(context);
  }
  
  void _setIsAcceptingLessonRequest(bool isAccepting) {
    setState(() {
      _isAcceptingLessonRequest = isAccepting;
    });  
  }

  void _afterLayout(_) {
    if (_lessonRequestProvider.shouldUnfocus) {
      _unfocus();
      _lessonRequestProvider.shouldUnfocus = false;
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
        child: _showAcceptLessonRequestDialog()
      ),
    );
  }
}