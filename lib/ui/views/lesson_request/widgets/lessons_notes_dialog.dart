import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/lesson_note_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class LessonsNotesDialog extends StatefulWidget {
  const LessonsNotesDialog({Key? key, this.student, this.lessonsNotes})
    : super(key: key);  

  final User? student;
  final List<LessonNote>? lessonsNotes;

  @override
  State<StatefulWidget> createState() => _LessonsNotesDialogState();
}

class _LessonsNotesDialogState extends State<LessonsNotesDialog> {
  LessonRequestViewModel? _lessonRequestProvider;
  final ScrollController _scrollController = ScrollController();    
  bool _areLessonsNotesRetrieved = false;

  Widget _showLessonsNotesDialog(bool isHorizontal) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(30.0, 25.0, 30.0, 20.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showLessonsNotes(isHorizontal),
          _showCloseButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Center(
        child: Text(
          widget.student?.name as String,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showLessonsNotes(bool isHorizontal) {
    List<Widget> lessonNoteWidgets = [];
    DateFormat dateFormat = DateFormat(AppConstants.dateFormat, 'en');
    if (widget.lessonsNotes != null) {
      for (LessonNote lessonNote in widget.lessonsNotes as List<LessonNote>) {
        String lessonNoteDate = dateFormat.format(lessonNote.dateTime as DateTime);
        Widget lessonNoteWidget = Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                lessonNoteDate,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  height: 1.5
                )
              ),
              Text(
                lessonNote.text as String,
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.DOVE_GRAY
                )
              )
            ]
          ),
        );
        lessonNoteWidgets.add(lessonNoteWidget);
      }
    }

    if (_areLessonsNotesRetrieved) {
      double height = 250.0;
      if (isHorizontal) {
        height = MediaQuery.of(context).size.height * 0.4;
      }      
      return Stack(
        children: [
          if (widget.lessonsNotes?.length == 0) Text(
            'lesson_request.no_notes_previous_mentors'.tr(),
            style: TextStyle(
              fontSize: 12.0,
              color: AppColors.DOVE_GRAY
            )
          ),
          Container(
            height: height,
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Scrollbar(
              controller: _scrollController,
              child: ListView(
                controller: _scrollController,
                children: lessonNoteWidgets
              )
            )
          ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 30.0, bottom: 50.0),
        child: Loader(color: AppColors.DOVE_GRAY)
      );
    }
  }
  
  Widget _showCloseButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.BERMUDA_GRAY,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          padding: const EdgeInsets.fromLTRB(40.0, 5.0, 40.0, 5.0),
        ),
        child: Text(
          'common.close'.tr(),
          style: const TextStyle(color: Colors.white)
        ),
        onPressed: () {
          Navigator.pop(context);
        }
      ),
    );
  }
  
  Future<void> _getLessonsNotes() async {
    if (!_areLessonsNotesRetrieved) {
      await _lessonRequestProvider?.getLessonsNotes(widget.student?.id as String);
      _areLessonsNotesRetrieved = true;
    } 
  }
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return FutureBuilder<void>(
      future: _getLessonsNotes(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return OrientationBuilder(
          builder: (context, orientation){
            if (orientation == Orientation.portrait) {
              return _showLessonsNotesDialog(false);
            } else {
              return _showLessonsNotesDialog(true);
            }
          }
        );
      }
    );
  }
}