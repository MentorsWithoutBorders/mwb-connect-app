import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class LearnedTodayDialog extends StatefulWidget {
  const LearnedTodayDialog({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _LearnedTodayDialogState();
}

class _LearnedTodayDialogState extends State<LearnedTodayDialog> {
  ConnectWithMentorViewModel? _connectWithMentorProvider;  
  final ScrollController _scrollController = ScrollController();  
  List<bool> _selectedSkills = [];
  bool _isMentorAbsent = false;
  bool _areMentorSkillsRetrieved = false;
  bool _isSubmitting = false;

  Widget _showLearnedTodayDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showSkills(),
          _showDivider(),
          _showMentorPresence(),
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
          'connect_with_mentor.learned_today'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    bool isRecurrent = false;
    if (_connectWithMentorProvider?.previousLesson != null && _connectWithMentorProvider?.previousLesson?.isRecurrent != null) {
      isRecurrent = _connectWithMentorProvider?.previousLesson?.isRecurrent as bool;
    }
    String recurrence = isRecurrent ? 'connect_with_mentor.learned_today_recurrence'.tr() : 'connect_with_mentor.learned_today_next_lesson'.tr();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        'connect_with_mentor.learned_today_text'.tr(args: [recurrence]),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.DOVE_GRAY,
          height: 1.2
        )
      ),
    );
  }

  Widget _showSkills() {
    List<Skill>? skills = _connectWithMentorProvider?.mentorSkills != null ? _connectWithMentorProvider?.mentorSkills : [];
    _initSkillCheckBoxes(skills as List<Skill>);
    List<Widget> skillWidgets = [];
    for (int i = 0; i < skills.length; i++) {
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
                skills[i].name as String,
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
    double height = 250.0;
    if (skillWidgets.length < 7) {
      height = skillWidgets.length * 40.0;
    }
    double heightScrollThumb = 250.0 / (skillWidgets.length / 6);

    if (_areMentorSkillsRetrieved) {
      return Container(
        height: height,
        padding: const EdgeInsets.only(left: 50.0, bottom: 10.0),
        child: DraggableScrollbar(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            children: skillWidgets
          ),
          heightScrollThumb: heightScrollThumb,
          backgroundColor: AppColors.SILVER,
          scrollThumbBuilder: (
            Color backgroundColor,
            Animation<double> thumbAnimation,
            Animation<double> labelAnimation,
            double height, {
            Text? labelText,
            BoxConstraints? labelConstraints
          }) {
            return FadeTransition(
              opacity: thumbAnimation,
              child: Container(
                height: height,
                width: 5.0,
                color: backgroundColor,
              ),
            );
          }        
        )
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 30.0, bottom: 50.0),
        child: Loader(color: AppColors.DOVE_GRAY)
      );
    }
  }

  void _initSkillCheckBoxes(List<Skill> skills) {
    for (int i = 0; i < skills.length; i++) {
      _selectedSkills.add(false);
    }
  }

  Widget _showDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: 10.0),
      color: AppColors.BOTTICELLI
    );
  }
  
  Widget _showMentorPresence() {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, bottom: 20.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 35.0,
            height: 35.0,                      
            child: Checkbox(
              activeColor: AppColors.TANGO,
              value: _isMentorAbsent,
              onChanged: (value) {
                _setIsMentorPresent();
              },
            ),
          ),
          InkWell(
            child: Text(
              'connect_with_mentor.mentor_not_present'.tr(),
              style: TextStyle(
                fontSize: 12.0,
                color: AppColors.DOVE_GRAY
              )
            ),
            onTap: () {
              _setIsMentorPresent();
            }
          )
        ]
      ),
    ); 
  }

  void _setSelectedSkills(int index) {
    setState(() {
      _selectedSkills[index] = !_selectedSkills[index];
    });
  }

  void _setIsMentorPresent() {
    setState(() {
      _isMentorAbsent = !_isMentorAbsent;
    });    
  }
  
  Widget _showSubmitButton() {
   return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.JAPANESE_LAUREL,
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
            await _submitLearnedToday();
            Navigator.pop(context);
          }
        ),
      ),
    );
  }

  Future<void> _submitLearnedToday() async {
    _setIsSubmitting(true);
    await _connectWithMentorProvider?.addSkills(_selectedSkills);
    await _connectWithMentorProvider?.setMentorPresence(!_isMentorAbsent);
    _showToast();
  }

  void _showToast() {
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('connect_with_mentor.learned_today_sent'.tr()),
        action: SnackBarAction(
          label: 'common.close'.tr(), onPressed: scaffold.hideCurrentSnackBar
        ),
      ),
    );
  }  

  void _setIsSubmitting(bool isSubmitting) {
    setState(() {
      _isSubmitting = isSubmitting;
    });  
  }    
  
  Future<void> _getMentorSkills() async {
    if (!_areMentorSkillsRetrieved) {
      await _connectWithMentorProvider?.getMentorSkills();
      _areMentorSkillsRetrieved = true;
    }
  }

  Future<bool> _onWillPop() async {
    if (!checkEmptySkills() || _isMentorAbsent) {
      await _submitLearnedToday();
    }
    return true;
  }

  bool checkEmptySkills() {
    bool isEmpty = true;
    for (bool selectedSkill in _selectedSkills) {
      if (selectedSkill == true) {
        isEmpty = false;
        break;
      }
    }
    return isEmpty;
  }  
  
  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

   return FutureBuilder<void>(
      future: _getMentorSkills(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: _showLearnedTodayDialog()
        );
      }
   );
  }
}