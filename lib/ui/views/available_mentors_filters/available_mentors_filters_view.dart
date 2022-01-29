import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors_filters/widgets/availabilities_list_widget.dart';
import 'package:mwb_connect_app/ui/views/available_mentors_filters/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/available_mentors_filters/widgets/subfields_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/app_card_widget.dart';

class AvailableMentorsFiltersView extends StatefulWidget {
  const AvailableMentorsFiltersView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _AvailableMentorsFiltersViewState();
}

class _AvailableMentorsFiltersViewState extends State<AvailableMentorsFiltersView> {
  AvailableMentorsViewModel? _availableMentorsProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }
  
  void _afterLayout(_) {

  }

  Widget _showAvailableMentorsFilters() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
      child: ListView(
        padding: const EdgeInsets.only(top: 0.0),
        children: [
          _showDaysTimesCard(),
          _showFieldsCard(),
          _showSetFiltersButton()
        ]
      )
    );
  }

  Widget _showDaysTimesCard() {
    return AppCard(
      child: AvailabilitiesList()
    );
  }

  Widget _showFieldsCard() {
    bool isAllFieldsSelected = _availableMentorsProvider?.isAllFieldsSelected as bool;
    return AppCard(
      child: Wrap(
        children: [
          FieldDropdown(),
          if (!isAllFieldsSelected) Subfields()
        ],
      )
    );
  }
  
  Widget _showSetFiltersButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
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
            _availableMentorsProvider?.getAvailableMentors();
            Navigator.pop(context);
          }        
        )
      ),
    );
  }  

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text('available_mentors.title_filters'.tr()),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

    return Stack(
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
          body: _showAvailableMentorsFilters()
        )
      ],
    );
  }
}
