import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/tag_widget.dart';

class Skills extends StatefulWidget {
  const Skills({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _SkillsState();
}

class _SkillsState extends State<Skills> {
  ProfileViewModel _profileProvider;
  final TextEditingController _typeAheadController = TextEditingController();
  GlobalKey _keyTypeahead = GlobalKey();

  Widget _showSkills() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
          decoration: BoxDecoration(
            color: AppColors.LINEN,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))
          ),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5.0, bottom: 7.0),
                child: Tag(
                  color: AppColors.TAN_HIDE,
                  text: 'HTML',
                  deleteImg: 'assets/images/delete_circle_icon.png',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0, bottom: 7.0),
                child: Tag(
                  color: AppColors.TAN_HIDE,
                  text: 'CSS',
                  deleteImg: 'assets/images/delete_circle_icon.png',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0, bottom: 7.0),
                child: Tag(
                  color: AppColors.TAN_HIDE,
                  text: 'JavaScript',
                  deleteImg: 'assets/images/delete_circle_icon.png',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0, bottom: 7.0),
                child: Tag(
                  color: AppColors.TAN_HIDE,
                  text: 'Python',
                  deleteImg: 'assets/images/delete_circle_icon.png',
                ),
              )
            ],
          )
        ),
        Container(
          height: 35.0,
          child: TypeAheadField(
            key: _keyTypeahead,
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.LINEN,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.fromLTRB(15.0, 0.0, 10.0, 5.0),
                hintText: 'Add skill (e.g. HTML, CSS, JavaScript, etc.)',
                hintStyle: const TextStyle(
                  fontSize: 14.0,
                  color: AppColors.SILVER
                ),
              ),
              style: TextStyle(
                fontSize: 14.0,
              ),
              controller: _typeAheadController,
            ),
            suggestionsCallback: (pattern) async {
              return _getSuggestions(pattern);
            },
            transitionBuilder:
                (context, suggestionsBox, controller) {
              return suggestionsBox;
            },
            itemBuilder: (context, suggestion) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 10.0),
                child: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              _typeAheadController.text = suggestion;
            }
          ),
        )
      ]
    );
  }

  static final List<String> skills = [
    'HTML',
    'CSS',
    'JavaScript',
    'Python',
    'Flask',
    'Django',
    'Java',
    'Spring',
    'Hibernate'
  ];

  List<String> _getSuggestions(String query) {
    List<String> matches = [];
    matches.addAll(skills);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    final RenderBox renderBoxTypeahead = _keyTypeahead.currentContext.findRenderObject();
    final positionTypeahead = renderBoxTypeahead.localToGlobal(Offset.zero);
    _profileProvider.setScrollOffset(positionTypeahead.dy); 
    return matches;
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