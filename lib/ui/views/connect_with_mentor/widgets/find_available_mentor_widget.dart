import 'package:flutter/material.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors_fields/available_mentors_fields_view.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/find_available_mentor_options_dialog_widget.dart';

class FindAvailableMentor extends StatefulWidget {
  const FindAvailableMentor({Key? key, this.shouldReloadCallback})
    : super(key: key);
    
  final VoidCallback? shouldReloadCallback;    

  @override
  State<StatefulWidget> createState() => _FindAvailableMentorState();
}

class _FindAvailableMentorState extends State<FindAvailableMentor> with TickerProviderStateMixin {
  ConnectWithMentorViewModel? _connectWithMentorProvider;

  Widget _showFindAvailableMentorCard() {
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
                padding: const EdgeInsets.only(left: 3.0),
                child: Wrap(
                  children: [
                    _showTopText(),
                    _showFindMentorButton()
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
          'connect_with_mentor.find_available_mentor'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.TANGO,
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }   

  Widget _showTopText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        'connect_with_mentor.next_lesson'.tr(),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 13.0,
          color: AppColors.DOVE_GRAY,
          height: 1.4
        ),
      )
    );
  }

  Widget _showFindMentorButton() {
    Lesson? previousLesson = _connectWithMentorProvider?.previousLesson;
    bool shouldShowOptionsDialog = previousLesson?.mentor != null && previousLesson?.isCanceled != true;
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            backgroundColor: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ),
          child: Text(
            'connect_with_mentor.find_mentor'.tr(),
            style: const TextStyle(color: Colors.white)
          ),
          onPressed: () async {
            if (shouldShowOptionsDialog) {
              _showFindMentorOptionsDialog();
            } else {
              await _goToAvailableMentorsFields();
            }
          }
        )
      )
    );
  }

  Future<void> _goToAvailableMentorsFields() async {
    final shouldReload = await Navigator.push(context, MaterialPageRoute(builder: (_) => AvailableMentorsFieldsView(shouldReloadCallback: widget.shouldReloadCallback)));
    if (shouldReload == true) {
      widget.shouldReloadCallback!();
    }
  }
  
  void _showFindMentorOptionsDialog() {
    Lesson? previousLesson = _connectWithMentorProvider?.previousLesson;
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: FindAvailableMentorOptionsDialog(
          mentor: previousLesson?.mentor,
          shouldReloadCallback: widget.shouldReloadCallback,
          context: context
        )
      )
    ).then((shouldReload) {
      if (shouldReload == true) {
        widget.shouldReloadCallback!();
      } else if (shouldReload == false) {
        _goToAvailableMentorsFields();
      }
    });     
  }   

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showFindAvailableMentorCard();
  }
}