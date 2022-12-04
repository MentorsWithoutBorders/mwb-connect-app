import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/cancel_mentor_partnership_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class WaitingMentorPartnershipRequest extends StatefulWidget {
  const WaitingMentorPartnershipRequest({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _WaitingMentorPartnershipRequestState();
}

class _WaitingMentorPartnershipRequestState extends State<WaitingMentorPartnershipRequest> {
  Widget _showWaitingMentorPartnershipRequestCard() {
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
          child: Wrap(
            children: [
              _showText(),
              _showFindPartnerButton(),
              _showCancelButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 7.0),
          child: Text(
            'mentor_course.waiting_mentor_partnership_request_text'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.DOVE_GRAY,
              height: 1.4
            )
          )
        )
      ]
    ); 
  }

  Widget _showFindPartnerButton() {
    String buttonText = 'mentor_course.find_partner'.tr();
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 10.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(color: Colors.white)
          ),
          onPressed: () async {
 
          }
        )
      )
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
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ), 
          child: Text('common.cancel_request'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AnimatedDialog(
                widgetInside: CancelMentorPartnershipRequestDialog()
              )
            ); 
          }
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showWaitingMentorPartnershipRequestCard();
  }
}