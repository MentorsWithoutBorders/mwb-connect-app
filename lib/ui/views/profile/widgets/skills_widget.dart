import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/tag_widget.dart';

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
  GlobalKey _keyTypeahead = GlobalKey();

  Widget _showSkills() {
    final List<Widget> skillWidgets = [];
    final List<String> skills = _profileProvider.profile.user.subfields[widget.index].skills;
    if (skills != null) {
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
            key: _keyTypeahead,
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
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
              style: TextStyle(
                fontSize: 14.0,
              ),
              controller: _typeAheadController,
              onSubmitted: (skill) {
                _addSkill(skill);
              },
            ),
            suggestionsCallback: (pattern) async {
              _doScroll();
              return _profileProvider.getSkillSuggestions(pattern, widget.index);
            },
            transitionBuilder: (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            itemBuilder: (context, suggestion) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 10.0),
                child: Text(suggestion),
              );
            },
            onSuggestionSelected: (skill) {
              _addSkill(skill);
            }         
          ),
        )
      ]
    );
  }

  void _doScroll() {
    final RenderBox renderBoxTypeahead = _keyTypeahead.currentContext.findRenderObject();
    final positionTypeahead = renderBoxTypeahead.localToGlobal(Offset.zero);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    _profileProvider.setScrollOffset(positionTypeahead.dy, screenHeight, statusBarHeight); 
  }  

  void _addSkill(String skill) {
    _typeAheadController.text = '';
    _profileProvider.addSkill(skill, widget.index);
  }
  
  void _deleteSkill(String skill) {
    _profileProvider.deleteSkill(skill, widget.index);
  }   
  
  void _unfocus() {
    _profileProvider.shouldUnfocus = true;
  } 

  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showSkills();
  }
}