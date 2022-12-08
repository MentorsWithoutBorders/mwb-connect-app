import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class RejectMentorPartnershipRequestDialog extends StatefulWidget {
  const RejectMentorPartnershipRequestDialog({Key? key})
    : super(key: key);
    
  @override
  State<StatefulWidget> createState() => _RejectMentorPartnershipRequestDialogState();
}

class _RejectMentorPartnershipRequestDialogState extends State<RejectMentorPartnershipRequestDialog> {
  MentorCourseViewModel? _mentorCourseProvider;
  String? _reasonText;
  bool _isRejectingMentorPartnershipRequest = false;

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
    MentorPartnershipRequestModel? mentorPartnershipRequest = _mentorCourseProvider?.mentorPartnershipRequest;
    CourseMentor mentor = mentorPartnershipRequest?.mentor as CourseMentor;
    CourseMentor partnerMentor = mentorPartnershipRequest?.partnerMentor as CourseMentor;
    String courseDayOfWeek = mentorPartnershipRequest?.courseDayOfWeek as String;
    String courseStartTime = mentorPartnershipRequest?.courseStartTime as String;
    String courseDuration = mentorPartnershipRequest?.courseType?.duration.toString() as String;
    String partnerMentorName = partnerMentor.name as String;
    Subfield mentorSubfield = _mentorCourseProvider?.getMentorSubfield(mentor) as Subfield;
    Subfield partnerMentorSubfield = _mentorCourseProvider?.getMentorSubfield(partnerMentor) as Subfield;
    String subfieldName = mentorSubfield.name!;
    if (partnerMentorSubfield.id != null && mentorSubfield.id != partnerMentorSubfield.id) {
      subfieldName = mentorSubfield.name! + ' ' + 'common.and'.tr() + ' ' + partnerMentorSubfield.name!;
    }
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String at = 'common.at'.tr();
    String text = 'mentor_course.reject_mentor_partnership_request_text'.tr(args: [partnerMentorName, courseDuration, subfieldName, courseDayOfWeek, courseStartTime, timeZone]);
    String firstPart = text.substring(0, text.indexOf(partnerMentorName));
    String secondPart = text.substring(text.indexOf(partnerMentorName) + partnerMentorName.length, text.indexOf(courseDuration));
    String thirdPart = text.substring(text.indexOf(courseDuration) + courseDuration.length, text.indexOf(subfieldName));
    String fourthPart = text.substring(text.indexOf(subfieldName) + subfieldName.length, text.indexOf(courseDayOfWeek));

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: RichText(
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.DOVE_GRAY,
                height: 1.4
              ),
              children: <TextSpan>[
                TextSpan(
                  text: firstPart
                ),
                TextSpan(
                  text: partnerMentorName,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: secondPart
                ),
                TextSpan(
                  text: courseDuration,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: thirdPart
                ),
                TextSpan(
                  text: subfieldName,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: fourthPart
                ),
                TextSpan(
                  text: courseDayOfWeek,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: ' ' + at + ' '
                ),
                TextSpan(
                  text: courseStartTime + ' ' + timeZone,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: '.'
                )
              ]
            )
          )
        )
      ]
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
          fontSize: 12.0
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
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          child: !_isRejectingMentorPartnershipRequest ? Text(
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
    _setIsRejectingMentorPartnershipRequest(true);
    await _mentorCourseProvider?.rejectMentorPartnershipRequest(_reasonText);
  }
  
  void _setIsRejectingMentorPartnershipRequest(bool isRejecting) {
    setState(() {
      _isRejectingMentorPartnershipRequest = isRejecting;
    });  
  }
  
  void _unfocus() {
    FocusScope.of(context).unfocus();
  }  
  
  @override
  Widget build(BuildContext context) {
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _unfocus();
      },
      child: _showRejectMentorPartnershipRequestDialog()
    );    
  }
}