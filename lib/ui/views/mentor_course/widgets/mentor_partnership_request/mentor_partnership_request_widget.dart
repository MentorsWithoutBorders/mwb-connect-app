import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/mentor_partnership_request/accept_mentor_partnership_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/mentor_partnership_request/reject_mentor_partnership_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class MentorPartnershipRequest extends StatefulWidget {
  const MentorPartnershipRequest({Key? key, this.text, this.bottomText, this.onAccept, this.onReject, this.shouldUnfocus, this.setShouldUnfocus})
    : super(key: key); 

  final List<ColoredText>? text;
  final List<ColoredText>? bottomText;
  final Function(String?)? onAccept;
  final Function(String?)? onReject;
  final bool? shouldUnfocus;
  final Function(bool)? setShouldUnfocus;

  @override
  State<StatefulWidget> createState() => _MentorPartnershipRequestState();
}

class _MentorPartnershipRequestState extends State<MentorPartnershipRequest> {

  Widget _showMentorPartnershipRequestCard() {
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
                _showButtons(),
                _showBottomText()
              ]
            ),
          )
        ),
      ),
    );
  }

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: MulticolorText(
        coloredTexts: widget.text as List<ColoredText>
      ),
    );
  }

  Widget _showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 30.0,
          margin: const EdgeInsets.only(bottom: 10.0, right: 15.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 1.0,
              backgroundColor: AppColors.MONZA,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
            ), 
            child: Text('common.reject'.tr(), style: const TextStyle(color: Colors.white)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AnimatedDialog(
                  widgetInside: RejectMentorPartnershipRequestDialog(
                    onReject: widget.onReject
                  ),
                  marginBottom: 210.0
                ),
              );
            }
          ),
        ),
        Container(
          height: 30.0,
          margin: const EdgeInsets.only(bottom: 10.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 1.0,
              backgroundColor: AppColors.JAPANESE_LAUREL,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
            ), 
            child: Text('common.accept'.tr(), style: const TextStyle(color: Colors.white)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AnimatedDialog(
                  widgetInside: AcceptMentorPartnershipRequestDialog(
                    onAccept: widget.onAccept,
                    shouldUnfocus: widget.shouldUnfocus,
                    setShouldUnfocus: widget.setShouldUnfocus
                  ),
                  marginBottom: 220.0
                ),
              );
            }
          ),
        ),
      ]
    );
  }

  Widget _showBottomText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: MulticolorText(
        coloredTexts: widget.bottomText as List<ColoredText>
      ),
    );
  }    

  @override
  Widget build(BuildContext context) {
    return _showMentorPartnershipRequestCard();
  }
}