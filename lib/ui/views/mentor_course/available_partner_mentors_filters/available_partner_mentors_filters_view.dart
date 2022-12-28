import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/available_partner_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/available_partner_mentors_filters/widgets/availabilities_list_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/available_partner_mentors_filters/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/available_partner_mentors_filters/widgets/subfields_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';

class AvailablePartnerMentorsFiltersView extends StatefulWidget {
  const AvailablePartnerMentorsFiltersView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _AvailablePartnerMentorsFiltersViewState();
}

class _AvailablePartnerMentorsFiltersViewState extends State<AvailablePartnerMentorsFiltersView> {
  AvailablePartnerMentorsViewModel? _availablePartnerMentorsProvider;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }  

  Widget _showAvailablePartnerMentorsFilters() {
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
                _showDaysTimesCard(),
                _showFieldsCard(),
              ]
            ),
          ),
          _showApplyFiltersButton()
        ],
      ),
    );
  }

  Widget _showDaysTimesCard() {
    return AppCard(
      child: AvailabilitiesList()
    );
  }

  Widget _showFieldsCard() {
    bool isAllFieldsSelected = _availablePartnerMentorsProvider?.isAllFieldsSelected as bool;
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            FieldDropdown(),
            if (!isAllFieldsSelected) Subfields()
          ]
        )
      )
    );
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
            _getAvailableMentors();
          }        
        )
      ),
    );
  }
  
  void _getAvailableMentors() {
    _availablePartnerMentorsProvider?.mentorsWaitingRequests = [];
    _availablePartnerMentorsProvider?.setErrorMessage('');
    _availablePartnerMentorsProvider?.setAvailabilityOptionId(null);
    _availablePartnerMentorsProvider?.setSubfieldOptionId(null);
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
    if (_availablePartnerMentorsProvider?.shouldUnfocus == true) {
      _unfocus();
      _availablePartnerMentorsProvider?.shouldUnfocus = false;
    }

    if (_availablePartnerMentorsProvider?.scrollOffset != 0) {
      _scrollToPosition(_availablePartnerMentorsProvider?.scrollOffset as double);
      _availablePartnerMentorsProvider?.scrollOffset = 0;
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
    _availablePartnerMentorsProvider = Provider.of<AvailablePartnerMentorsViewModel>(context);

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
            body: _showAvailablePartnerMentorsFilters()
          )
        ],
      ),
    );
  }
}
