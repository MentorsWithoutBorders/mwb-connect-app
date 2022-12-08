import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/cancel_mentor_partnership_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class WaitingMentorPartnershipApproval extends StatefulWidget {
  const WaitingMentorPartnershipApproval({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _WaitingMentorPartnershipApprovalState();
}

class _WaitingMentorPartnershipApprovalState extends State<WaitingMentorPartnershipApproval> {
  MentorCourseViewModel? _mentorCourseProvider;  

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
          child: Wrap(
            children: [
              _showText(),
              _showCancelButton()
            ]
          )
        ),
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
    String text = 'mentor_course.waiting_mentor_partnership_text'.tr(args: [partnerMentorName, courseDuration, subfieldName, courseDayOfWeek, courseStartTime, timeZone]);
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
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 7.0),
          child: Text(
            'mentor_course.waiting_mentor_partnership_approval_text'.tr(),
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
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);

    return _showWaitingMentorPartnershipApprovalCard();
  }
}