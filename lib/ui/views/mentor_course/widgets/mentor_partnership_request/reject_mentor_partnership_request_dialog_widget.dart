import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class RejectMentorPartnershipRequestDialog extends StatefulWidget {
  const RejectMentorPartnershipRequestDialog({Key? key, this.onReject})
    : super(key: key);

  final Function(String?)? onReject;
    
  @override
  State<StatefulWidget> createState() => _RejectMentorPartnershipRequestDialogState();
}

class _RejectMentorPartnershipRequestDialogState extends State<RejectMentorPartnershipRequestDialog> {
  String? _reasonText;
  bool _isRejecting = false;

  Widget _showRejectMentorPartnershipRequestDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showReasonInput(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    String title = 'mentor_course.reject_mentor_partnership_request'.tr();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          title,
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
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        'mentor_course.reject_mentor_partnership_request_text'.tr(),
        style: const TextStyle(
          fontSize: 14.0,
          color: AppColors.DOVE_GRAY,
          height: 1.5
        ),
        textAlign: TextAlign.justify
      )
    );
  }

  Widget _showReasonInput() {
    return Container(
      height: 80.0,
      margin: const EdgeInsets.only(bottom: 15.0),        
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.SILVER)
      ),
      child: TextFormField(
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 13.0
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),          
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: const TextStyle(color: AppColors.SILVER),
          hintText: 'common.reject_reason_placeholder'.tr(),
        ),
        onChanged: (String? value) => _reasonText = value?.trim(),
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
            backgroundColor: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          child: !_isRejecting ? Text(
            'common.yes_reject'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 70.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _rejectMentorPartnershipRequest();
            Navigator.pop(context);
          },
        )
      ]
    );
  } 

  Future<void> _rejectMentorPartnershipRequest() async {  
    _setIsRejecting(true);
    await widget.onReject!(_reasonText);
  }
  
  void _setIsRejecting(bool isRejecting) {
    setState(() {
      _isRejecting = isRejecting;
    });  
  }
  
  void _unfocus() {
    FocusScope.of(context).unfocus();
  }  
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _unfocus();
      },
      child: _showRejectMentorPartnershipRequestDialog()
    );    
  }
}