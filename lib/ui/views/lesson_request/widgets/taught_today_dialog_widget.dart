import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class TaughtTodayDialog extends StatefulWidget {
  const TaughtTodayDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _TaughtTodayDialogState();
}

class _TaughtTodayDialogState extends State<TaughtTodayDialog> {
  LessonRequestViewModel _lessonRequestProvider;  
  final ScrollController _scrollController = ScrollController();  
  final GlobalKey _skillsListKey = GlobalKey();
  int _skillsNumber = 0;
  List<bool> _selectedSkills = [];
  double _skillsHeight = 0.0;
  double _scrollThumbHeight = 20.0;
  String _lessonNote = '';
  bool _isKeyboardOpen = false;
  bool _areSkillsRetrieved = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initKeyboard();
  }

  void _initKeyboard() {
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (visible) {
          _isKeyboardOpen = true;
        } else {
          _isKeyboardOpen = false;
        }
      }
    );    
  } 

  Widget _showTaughtTodayDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showSkills(),
          _showLessonNoteInput(),
          _showSubmitButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          'lesson_request.taught_today'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    int studentsNumber = _lessonRequestProvider.previousLesson.students.length;
    bool isRecurrent = _lessonRequestProvider.previousLesson.isRecurrent;
    String studentPlural = plural('student', studentsNumber);
    String pronoun = studentsNumber == 1 ? 'common.him_her'.tr() : 'common.them'.tr();
    String throughoutRecurrence = '';
    if (isRecurrent != null && isRecurrent) {
      throughoutRecurrence = ' ' + 'lesson_request.throughout_recurrence'.tr();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        'lesson_request.taught_today_text'.tr(args: [studentPlural, pronoun, throughoutRecurrence]),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 12.0,
          color: AppColors.DOVE_GRAY,
          height: 1.2
        )
      ),
    );
  }

  Widget _showSkills() {
    List<Skill> skills = _lessonRequestProvider.skills != null ? _lessonRequestProvider.skills : [];
    _skillsNumber = skills.length;
    _initSkillCheckBoxes(skills);
    List<Widget> skillWidgets = [];
    for (int i = 0; i < _skillsNumber; i++) {
      Widget skillWidget = Row(
        children: <Widget>[
          SizedBox(
            width: 40.0,
            height: 35.0,
            child: Checkbox(
              activeColor: AppColors.TANGO,
              value: _selectedSkills[i],
              onChanged: (value) {
                _setSelectedSkills(i);
              },
            ),
          ),
          Expanded(
            child: InkWell(
              child: Text(
                skills[i].name,
                style: TextStyle(
                  fontSize: 12.0,
                  color: _selectedSkills[i] ? Colors.black : AppColors.DOVE_GRAY
                )
              ),
              onTap: () {
                _setSelectedSkills(i);
              }
            ),
          )
        ]
      );
      skillWidgets.add(skillWidget);
    }

    if (_areSkillsRetrieved) {
      WidgetsBinding.instance.addPostFrameCallback(_afterSkillsLoaded);
      return Stack(
        children: [
          Offstage(
            offstage: true,
            child: _showSkillsListView(skillWidgets, _skillsListKey)
          ),
          Container(
            height: _skillsHeight,
            padding: const EdgeInsets.only(left: 50.0, bottom: 20.0),
            child: DraggableScrollbar(
              controller: _scrollController,
              child: _showSkillsListView(skillWidgets, null),
              heightScrollThumb: _scrollThumbHeight,
              backgroundColor: AppColors.SILVER,
              scrollThumbBuilder: (
                Color backgroundColor,
                Animation<double> thumbAnimation,
                Animation<double> labelAnimation,
                double height, {
                Text labelText,
                BoxConstraints labelConstraints
              }) {
                return FadeTransition(
                  opacity: thumbAnimation,
                  child: Container(
                    height: height,
                    width: 5.0,
                    color: backgroundColor,
                  )
                );
              }        
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

  Widget _showSkillsListView(List<Widget> skillWidgets, GlobalKey key) {
    return ListView(
      key: key,
      shrinkWrap: key == null ? false : true,
      controller: key == null ? _scrollController : null,
      children: skillWidgets
    );    
  }

  void _afterSkillsLoaded(_) {
    final RenderBox skillsBox = _skillsListKey.currentContext.findRenderObject();
    _calculateSkillsBoxParams(skillsBox.size.height);
  }

  void _calculateSkillsBoxParams(double skillsBoxHeight) {
    double scrollThumbHeight = 20.0;
    if (!_isKeyboardOpen) {
      if (skillsBoxHeight > 170) {
        scrollThumbHeight = 170 / (_skillsNumber / 4);
        _setSkillsBoxParams(170, scrollThumbHeight);
      } else {
        _setSkillsBoxParams(skillsBoxHeight + 20, 0);
      }
    } else {
      if (skillsBoxHeight > 70) {
        scrollThumbHeight = 70 / (_skillsNumber / 2);
        _setSkillsBoxParams(70, scrollThumbHeight);
      } else {
        _setSkillsBoxParams(skillsBoxHeight + 20, 0);
      }
    }   
  }

  void _setSkillsBoxParams(double skillsHeight, double scrollThumbHeight) {
    setState(() {
      _skillsHeight = skillsHeight;
      _scrollThumbHeight = scrollThumbHeight;
    });     
  }    

  void _initSkillCheckBoxes(List<Skill> skills) {
    for (int i = 0; i < skills.length; i++) {
      _selectedSkills.add(false);
    }
  }

  void _setSelectedSkills(int index) {
    setState(() {
      _selectedSkills[index] = !_selectedSkills[index];
    });
  }

  Widget _showLessonNoteInput() {
    return Container(
      height: 80.0,
      margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 20.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.SILVER),
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: TextFormField(
        maxLines: null,
        style: const TextStyle(
          fontSize: 13.0
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          isDense: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: const TextStyle(color: AppColors.SILVER),
          hintText: 'lesson_request.quick_notes_placeholder'.tr(),
        ),
        onChanged: (String value) => _lessonNote = value.trim(),
      ),
    );
  }
  
  Widget _showSubmitButton() {
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
            padding: const EdgeInsets.fromLTRB(50.0, 3.0, 50.0, 3.0),
          ), 
          child: !_isSubmitting ? Text(
            'common.submit'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 50.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _submitTaughtToday();
            Navigator.pop(context);
          }
        ),
      ),
    );
  }

  Future<void> _submitTaughtToday() async {
    _setIsSubmitting(true);
    await _lessonRequestProvider.addStudentSkills(_selectedSkills);
    await _lessonRequestProvider.addStudentsLessonNotes(_lessonNote);
  }

  void _setIsSubmitting(bool isSubmitting) {
    setState(() {
      _isSubmitting = isSubmitting;
    });  
  }    
  
  Future<void> _getSkills() async {
    if (!_areSkillsRetrieved) {
      await _lessonRequestProvider.getSkills();
      _areSkillsRetrieved = true;
    }
  }  
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

   return FutureBuilder<void>(
      future: _getSkills(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return _showTaughtTodayDialog();
      }
   );
  }
}