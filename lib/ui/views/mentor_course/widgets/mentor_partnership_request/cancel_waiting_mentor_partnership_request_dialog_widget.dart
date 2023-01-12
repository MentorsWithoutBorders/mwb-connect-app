import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class CancelWaitingMentorPartnershipRequestDialog extends StatefulWidget {
  const CancelWaitingMentorPartnershipRequestDialog({Key? key, @required this.onCancel})
    : super(key: key);
    
  final Function? onCancel;

  @override
  State<StatefulWidget> createState() => _CancelWaitingMentorPartnershipRequestDialogState();
}

class _CancelWaitingMentorPartnershipRequestDialogState extends State<CancelWaitingMentorPartnershipRequestDialog> with TickerProviderStateMixin {
  bool _isCanceling = false;

  Widget _showCancelWaitingMentorPartnershipRequestDialog() {
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
          'mentor_course.cancel_waiting_mentor_partnership_request'.tr(),
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
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        'mentor_course.cancel_waiting_mentor_partnership_request_text'.tr(),
        style: const TextStyle(
          fontSize: 15.0,
          color: AppColors.DOVE_GRAY,
          height: 1.5
        ),
        textAlign: TextAlign.justify
      )
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
          child: !_isCanceling ? Text(
            'common.yes_cancel'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 70.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _cancelWaitingMentorPartnershipRequest();
            Navigator.pop(context);
          },
        )
      ]
    );
  } 

  Future<void> _cancelWaitingMentorPartnershipRequest() async {  
    _setIsCanceling(true);
    await widget.onCancel!();
  }
  
  void _setIsCanceling(bool isCanceling) {
    setState(() {
      _isCanceling = isCanceling;
    });  
  }  
  
  @override
  Widget build(BuildContext context) {
    return _showCancelWaitingMentorPartnershipRequestDialog();
  }
}