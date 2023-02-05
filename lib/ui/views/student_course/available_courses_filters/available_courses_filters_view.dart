import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course/available_courses_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests_filters/widgets/availabilities_list_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests_filters/widgets/subfields_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';

class AvailableCoursesFiltersView extends StatefulWidget {
  const AvailableCoursesFiltersView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _AvailableCoursesFiltersViewState();
}

class _AvailableCoursesFiltersViewState extends State<AvailableCoursesFiltersView> {
  AvailableCoursesViewModel? _availableCoursesProvider;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }  

  Widget _showAvailableCoursesFilters() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
      child: Column(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 0.0),
              shrinkWrap: true,
              children: [
                _showAvailabilitiesCard(),
                _showSubfieldsCard(),
              ]
            ),
          ),
          _showApplyFiltersButton()
        ],
      ),
    );
  }

  Widget _showAvailabilitiesCard() {
    List<Availability> filterAvailabilities = _availableCoursesProvider?.filterAvailabilities ?? [];
    String mergedMessage = _availableCoursesProvider?.availabilityMergedMessage ?? '';
    return AppCard(
      child: AvailabilitiesList(
        filterAvailabilities: filterAvailabilities,
        mergedMessage: mergedMessage,
        onAdd: _onAddAvailability,
        onUpdate: _onUpdateAvailability,
        onDelete: _onDeleteAvailability,
        onResetMergedMessage: _onResetAvailabilityMergedMessage
      )
    );
  }

  Widget _showSubfieldsCard() {
    Field? filterField = _availableCoursesProvider?.filterField;
    Field? field = _availableCoursesProvider?.fields[0];
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            Subfields(
              filterField: filterField,
              field: field,
              onAdd: _addSubfield,
              onDelete: _deleteSubfield,
              onSet: _setSubfield,
              onAddSkill: _addSkill,
              onDeleteSkill: _deleteSkill,
              onSetScrollOffset: _setScrollOffset,
              onSetShouldUnfocus: _setShouldUnfocus
            )
          ]
        )
      )
    );
  }

  void _onAddAvailability(Availability availability) {
    _availableCoursesProvider?.addAvailability(availability);
  }

  void _onUpdateAvailability(int index, Availability availability) {
    _availableCoursesProvider?.updateAvailability(index, availability);
  }

  void _onDeleteAvailability(int index) {
    _availableCoursesProvider?.deleteAvailability(index);
  }

  void _onResetAvailabilityMergedMessage() {
    _availableCoursesProvider?.resetAvailabilityMergedMessage();
  }

  void _addSubfield() {
    _availableCoursesProvider?.addSubfield();
  }

  void _deleteSubfield(int index) {
    _availableCoursesProvider?.deleteSubfield(index);
  }

  void _setSubfield(Subfield subfield, int index) {
    _availableCoursesProvider?.setSubfield(subfield, index);
  }

  bool _addSkill(String skill, int index) {
    return _availableCoursesProvider?.addSkill(skill, index) as bool;
  }

  void _deleteSkill(String skillId, int index) {
    _availableCoursesProvider?.deleteSkill(skillId, index);
  }

  void _setScrollOffset(double positionDy, double screenHeight, double statusBarHeight) {
    _availableCoursesProvider?.setScrollOffset(positionDy, screenHeight, statusBarHeight);
  }

  void _setShouldUnfocus(bool shouldUnfocus) {
    _availableCoursesProvider?.shouldUnfocus = shouldUnfocus;
  }  
  
  Widget _showApplyFiltersButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10.0, bottom: 20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            elevation: 2.0,
            padding: const EdgeInsets.fromLTRB(30.0, 12.0, 30.0, 12.0)          
          ),
          child: Text('available_mentors.apply_filters'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            _getAvailableCourses();
          }        
        )
      ),
    );
  }
  
  void _getAvailableCourses() {
    _availableCoursesProvider?.availableCourses = [];
    Navigator.pop(context, true);    
  }

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'available_mentors.title_filters'.tr(),
          textAlign: TextAlign.center
        ),
      )
    );
  }

  void _afterLayout(_) {
    if (_availableCoursesProvider?.shouldUnfocus == true) {
      _unfocus();
      _availableCoursesProvider?.shouldUnfocus = false;
    }

    if (_availableCoursesProvider?.scrollOffset != 0) {
      _scrollToPosition(_availableCoursesProvider?.scrollOffset as double);
      _availableCoursesProvider?.scrollOffset = 0;
    }    
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  void _scrollToPosition(double offset) {
    Future<void>.delayed(const Duration(milliseconds: 1000), () {
      _scrollController.animateTo(
        _scrollController.position.pixels + offset,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });
  }    

  @override
  Widget build(BuildContext context) {
    _availableCoursesProvider = Provider.of<AvailableCoursesViewModel>(context);

    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);

    return GestureDetector(
      onTap: () {
        _unfocus();
      },
      child: Stack(
        children: <Widget>[
          const BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: _showTitle(),
              backgroundColor: Colors.transparent,          
              elevation: 0.0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(null),
              )
            ),
            extendBodyBehindAppBar: true,
            body: _showAvailableCoursesFilters()
          )
        ],
      ),
    );
  }
}
