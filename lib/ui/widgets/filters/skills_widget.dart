import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/ui/widgets/tag_widget.dart';
import 'package:mwb_connect_app/ui/widgets/typeahead_field_widget.dart';

class Skills extends StatefulWidget {
  const Skills({Key? key, @required this.index, @required this.filterField, @required this.fields, @required this.onAdd, @required this.onDelete, @required this.onSetScrollOffset})
    : super(key: key);
    
  final int? index;
  final Field? filterField;
  final List<Field>? fields;
  final Function(String, int)? onAdd;
  final Function(String, int)? onDelete;
  final Function(double, double, double)? onSetScrollOffset;

  @override
  State<StatefulWidget> createState() => _SkillsState();
}

class _SkillsState extends State<Skills> {
  final TextEditingController _typeAheadController = TextEditingController();
  final GlobalKey _keyTypeAhead = GlobalKey();
  String _query = '';

  Widget _showSkills() {
    final List<Widget> skillWidgets = [];
    final List<Skill>? skills = widget.filterField?.subfields?[widget.index!].skills;
    final Field filterField = widget.filterField as Field;
    List<Field> fields = widget.fields as List<Field>;
    if (skills != null && skills.isNotEmpty) {
      for (int i = 0; i < skills.length; i++) {
        final Widget skillWidget = Padding(
          padding: const EdgeInsets.only(right: 5.0, bottom: 7.0),
          child: Tag(
            color: AppColors.TAN_HIDE,
            id: skills[i].id as String,
            text: skills[i].name as String,
            deleteImg: 'assets/images/delete_circle_icon.png',
            tagDeletedCallback: _deleteSkill
          ),
        );
        skillWidgets.add(skillWidget);
      }
    }
    final double inputBorderRadiusTop = skillWidgets.isNotEmpty ? 0.0 : 10.0;
    final double inputHeight = skillWidgets.isNotEmpty ? 35.0 : 40.0;
    return Column(
      children: <Widget>[
        if (skillWidgets.isNotEmpty) Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
          decoration: const BoxDecoration(
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
            options: UtilsFields.getSkillSuggestions(_query, widget.index!, filterField, fields),
            inputDecoration: InputDecoration(
              filled: true,
              fillColor: AppColors.LINEN,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(inputBorderRadiusTop), topRight: Radius.circular(inputBorderRadiusTop), bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 5.0),
              hintText: UtilsFields.getSkillHintText(widget.index!, filterField, fields),
              hintStyle: const TextStyle(
                fontSize: 14.0,
                color: AppColors.SILVER
              ),
            ),
            inputController: _typeAheadController,
            onFocusCallback: () {
              _doScroll();
            },
            onChangedCallback: (String query) {
              _changeQuery(query);
            },            
            onSubmittedCallback: (String skill) {
              _addSkill(skill);
            },
            onSuggestionSelected: (String skill) {
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
    final RenderBox renderBoxTypeahead = _keyTypeAhead.currentContext?.findRenderObject() as RenderBox;
    final Offset positionTypeahead = renderBoxTypeahead.localToGlobal(Offset.zero);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    widget.onSetScrollOffset!(positionTypeahead.dy, screenHeight, statusBarHeight); 
  }
  

  void _addSkill(String skillName) {
    if (widget.onAdd!(skillName, widget.index!) == true) {
      _resetInputText();
    }
  }

  void _resetInputText() {
    _typeAheadController.value = TextEditingValue(
      text: '',
      selection: TextSelection.fromPosition(
        const TextPosition(offset: 0),
      )
    );
    setState(() {
      _query = '';
    });    
  }
  
  void _deleteSkill(String skillId) {
    widget.onDelete!(skillId, widget.index!);
  }

  @override
  Widget build(BuildContext context) {
    return _showSkills();
  }
}