import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/tag_widget.dart';
import 'package:mwb_connect_app/ui/widgets/typeahead_field_widget.dart';

class Skills extends StatefulWidget {
  const Skills({Key key, @required this.index})
    : super(key: key);
    
  final int index;    

  @override
  State<StatefulWidget> createState() => _SkillsState();
}

class _SkillsState extends State<Skills> {
  ProfileViewModel _profileProvider;
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey _keyTypeAhead = GlobalKey();
  String _query = '';

  Widget _showSkills() {
    final List<Widget> skillWidgets = [];
    final List<String> skills = _profileProvider.profile.user.subfields[widget.index].skills;
    if (skills != null && skills.length > 0) {
      for (int i = 0; i < skills.length; i++) {
        final Widget skill = Padding(
          padding: const EdgeInsets.only(right: 5.0, bottom: 7.0),
          child: Tag(
            color: AppColors.TAN_HIDE,
            text: skills[i],
            deleteImg: 'assets/images/delete_circle_icon.png',
            tagDeletedCallback: _deleteSkill
          ),
        );
        skillWidgets.add(skill);
      }
    }
    double inputBorderRadiusTop = skillWidgets.length > 0 ? 0.0 : 10.0;
    double inputHeight = skillWidgets.length > 0 ? 35.0 : 40.0;
    return Column(
      children: [
        if (skillWidgets.length > 0) Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
          decoration: BoxDecoration(
            color: AppColors.LINEN,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))
          ),
          child: Wrap(
            children: skillWidgets,
          )
        ),
        Container(
          height: inputHeight,
          child: TypeAheadField(
            key: _keyTypeAhead,
            options: _profileProvider.getSkillSuggestions(_query, widget.index),
            inputDecoration: InputDecoration(
              filled: true,
              fillColor: AppColors.LINEN,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(inputBorderRadiusTop), topRight: Radius.circular(inputBorderRadiusTop), bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 5.0),
              hintText: _profileProvider.getSkillHintText(widget.index),
              hintStyle: const TextStyle(
                fontSize: 14.0,
                color: AppColors.SILVER
              ),
            ),
            inputController: _typeAheadController,
            onFocusCallback: () {
              _doScroll();
            },
            onChangedCallback: (query) {
              _changeQuery(query);
            },            
            onSubmittedCallback: (skill) {
              _addSkill(skill);
            },
            onSuggestionSelected: (skill) {
              _addSkill(skill);
            }         
          ),
        )
      ]
    );
  }

  void _changeQuery(String query) {
    setState(() {
      _query = query;
    });
  }

  void _doScroll() {
    final RenderBox renderBoxTypeahead = _keyTypeAhead.currentContext.findRenderObject();
    final positionTypeahead = renderBoxTypeahead.localToGlobal(Offset.zero);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    _profileProvider.setScrollOffset(positionTypeahead.dy, screenHeight, statusBarHeight); 
  }  

  void _addSkill(String skill) {
    _profileProvider.addSkill(skill, widget.index);
    _resetInputText();
  }

  void _resetInputText() {
    _typeAheadController.value = TextEditingValue(
      text: '',
      selection: TextSelection.fromPosition(
        TextPosition(offset: 0),
      )
    );
    setState(() {
      _query = '';
    });    
  }
  
  void _deleteSkill(String skill) {
    _profileProvider.deleteSkill(skill, widget.index);
    _resetInputText();   
  }

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showSkills();
  }
}