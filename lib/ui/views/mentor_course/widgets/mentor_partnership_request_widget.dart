import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/accept_mentor_partnership_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/reject_mentor_partnership_request_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class MentorPartnershipRequest extends StatefulWidget {
  const MentorPartnershipRequest({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _MentorPartnershipRequestState();
}

class _MentorPartnershipRequestState extends State<MentorPartnershipRequest> {
  MentorCourseViewModel? _mentorCourseProvider;

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
    String text = 'mentor_course.mentor_partnership_request_text'.tr(args: [partnerMentorName, courseDuration, subfieldName, courseDayOfWeek, courseStartTime, timeZone]);
    String firstPart = text.substring(text.indexOf(partnerMentorName) + partnerMentorName.length, text.indexOf(courseDuration));
    String secondPart = text.substring(text.indexOf(courseDuration) + courseDuration.length, text.indexOf(subfieldName));
    String thirdPart = text.substring(text.indexOf(subfieldName) + subfieldName.length, text.indexOf(courseDayOfWeek));

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
                  text: partnerMentorName,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: firstPart
                ),
                TextSpan(
                  text: courseDuration,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  ) 
                ),
                TextSpan(
                  text: secondPart
                ),
                TextSpan(
                  text: subfieldName,
                  style: const TextStyle(
                    color: AppColors.TANGO
                  )
                ),
                TextSpan(
                  text: thirdPart
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
              primary: AppColors.MONZA,
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
                  widgetInside: RejectMentorPartnershipRequestDialog()
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
              primary: AppColors.JAPANESE_LAUREL,
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
                  widgetInside: AcceptMentorPartnershipRequestDialog()
                ),
              );
            }
          ),
        ),
      ]
    );
  }

  Widget _showBottomText() {
    MentorPartnershipRequestModel? mentorPartnershipRequest = _mentorCourseProvider?.mentorPartnershipRequest;
    DateTime sentDateTime = mentorPartnershipRequest?.sentDateTime as DateTime;
    CourseMentor partnerMentor = mentorPartnershipRequest?.partnerMentor as CourseMentor;
    String partnerMentorName = partnerMentor.name as String;
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    String date = dateFormat.format(sentDateTime.add(Duration(days: 1)));
    String text = 'mentor_course.mentor_partnership_request_bottom_text'.tr(args: [date, partnerMentorName]);
    String firstPart = text.substring(0, text.indexOf(date));
    String secondPart = text.substring(text.indexOf(date) + date.length, text.indexOf(partnerMentorName));
    String thirdPart = text.substring(text.indexOf(partnerMentorName) + partnerMentorName.length);

    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.DOVE_GRAY,
            fontStyle: FontStyle.italic,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: firstPart
            ),
            TextSpan(
              text: date,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: secondPart
            ),
            TextSpan(
              text: partnerMentorName,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: thirdPart
            )
          ]
        )
      ),
    );
  }    

  @override
  Widget build(BuildContext context) {
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);

    return _showMentorPartnershipRequestCard();
  }
}