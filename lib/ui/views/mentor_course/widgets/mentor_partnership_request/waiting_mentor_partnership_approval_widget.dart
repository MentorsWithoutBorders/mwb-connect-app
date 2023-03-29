import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/mentor_partnership_request/cancel_mentor_partnership_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class WaitingMentorPartnershipApproval extends StatefulWidget {
  const WaitingMentorPartnershipApproval({Key? key, this.partnerMentorName, this.text, this.onCancel})
    : super(key: key); 

  final String? partnerMentorName;
  final List<ColoredText>? text;
  final Function? onCancel;

  @override
  State<StatefulWidget> createState() => _WaitingMentorPartnershipApprovalState();
}

class _WaitingMentorPartnershipApprovalState extends State<WaitingMentorPartnershipApproval> {
  Widget _showWaitingMentorPartnershipApprovalCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.only(bottom: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), 
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 3.0, right: 3.0),
            child: Wrap(
              children: [
                _showText(),
                _showCancelButton()
              ]
            ),
          )
        ),
      ),
    );
  }

  Widget _showText() {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: MulticolorText(
            coloredTexts: widget.text as List<ColoredText>
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 7.0),
          child: Text(
            'mentor_course.waiting_mentor_partnership_approval_text'.tr(args: [widget.partnerMentorName as String]),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.DOVE_GRAY,
              height: 1.4
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Center(
            child: Text(
              'common.waiting_time'.tr(),
              style: const TextStyle(
                fontSize: 12.0,
                fontStyle: FontStyle.italic,
                color: AppColors.DOVE_GRAY,
                height: 1.4
              )
            )
          ),
        )
      ]
    ); 
  }

  Widget _showCancelButton() {
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            backgroundColor: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ), 
          child: Text('common.cancel_request'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AnimatedDialog(
                widgetInside: CancelMentorPartnershipRequestDialog(
                  onCancel: widget.onCancel
                )
              )
            ); 
          }
        ),
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    return _showWaitingMentorPartnershipApprovalCard();
  }
}