import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class CancelLessonRequestDialog extends StatefulWidget {
  const CancelLessonRequestDialog({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _CancelLessonRequestDialogState();
}

class _CancelLessonRequestDialogState extends State<CancelLessonRequestDialog> with TickerProviderStateMixin {
  ConnectWithMentorViewModel? _connectWithMentorProvider;
  bool _isCancelingLessonRequest = false;

  Widget _showCancelLessonRequestDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          'connect_with_mentor.cancel_lesson_request'.tr(),
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
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Text(
        'connect_with_mentor.cancel_lesson_request_text'.tr(),
        style: const TextStyle(
          fontSize: 15.0,
          color: AppColors.DOVE_GRAY,
          height: 1.5
        ),
        textAlign: TextAlign.justify
      ),
    );
  }
  
  Widget _showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
            child: Text('common.no_abort'.tr(), style: const TextStyle(color: Colors.grey))
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          child: !_isCancelingLessonRequest ? Text(
            'common.yes_cancel'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 70.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _cancelLessonRequest();
            Navigator.pop(context);
          },
        )
      ]
    );
  } 

  Future<void> _cancelLessonRequest() async {  
    _setIsCancelingLessonRequest(true);
    await _connectWithMentorProvider?.cancelLessonRequest();
  }
  
  void _setIsCancelingLessonRequest(bool isCanceling) {
    setState(() {
      _isCancelingLessonRequest = isCanceling;
    });  
  }  
  
  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showCancelLessonRequestDialog();
  }
}