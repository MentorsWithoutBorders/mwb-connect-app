import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/add_lessons_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class StandingBy extends StatefulWidget {
  const StandingBy({Key? key, this.reload})
    : super(key: key); 

  final Function? reload;

  @override
  State<StatefulWidget> createState() => _StandingByState();
}

class _StandingByState extends State<StandingBy> {
  LessonRequestViewModel? _lessonRequestProvider;

  Widget _showStandingByCard() {
    bool? isPreviousLesson = _lessonRequestProvider?.isPreviousLesson;
    List<User> previousLessonStudents = _lessonRequestProvider?.previousLesson?.students as List<User>;
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
              _showTitle(),
              Container(
                padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                child: Wrap(
                  children: [
                    _showText(),
                    if (isPreviousLesson == true && previousLessonStudents.length > 0) _showAddMoreLessons()
                  ]
                )
              )
            ],
          )
        ),
      ),
    );
  }

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(top: 3.0, bottom: 15.0),
      child: Center(
        child: Text(
          'lesson_request.standing_by'.tr(),
          style: const TextStyle(
            color: AppColors.TANGO,
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }   

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12.0,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'lesson_request.standing_by_text'.tr(),             
            ),
            TextSpan(
              text: 'common.your_profile'.tr(),
              style: const TextStyle(
                decoration: TextDecoration.underline
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                Navigator.push(context, MaterialPageRoute<ProfileView>(builder: (_) => ProfileView()));
              } 
            ),
            TextSpan(
              text: '.'
            )
          ]
        )
      ),
    );
  }

  Widget _showAddMoreLessons() {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              'common.or'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.0,
                fontStyle: FontStyle.italic,
                color: AppColors.TANGO
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'lesson_request.add_more_lessons_text'.tr(),
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 12.0,
                color: AppColors.DOVE_GRAY,
                height: 1.4
              )
            )
          ),
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(bottom: 5.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 1.0,
                primary: AppColors.ALLPORTS,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                ),
                padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
              ), 
              onPressed: () {
                _showAddLessonsDialog();
              },
              child: Text(
                'lesson_request.add_more_lessons'.tr(),
                style: const TextStyle(color: Colors.white)
              )
            )
          )
        ]
      ),
    );
  }

  void _showAddLessonsDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: AddLessonsDialog(lesson: _lessonRequestProvider?.previousLesson, reload: widget.reload)
      ),
    );    
  }   

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return _showStandingByCard();
  }
}