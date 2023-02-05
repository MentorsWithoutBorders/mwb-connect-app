import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests_filters/widgets/availability_item_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests_filters/widgets/add_availability_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class AvailabilitiesList extends StatefulWidget {
  const AvailabilitiesList({Key? key, this.filterAvailabilities, this.mergedMessage, this.onAdd, this.onUpdate, this.onDelete, this.onResetMergedMessage})
    : super(key: key);
    
  final List<Availability>? filterAvailabilities;
  final String? mergedMessage;
  final Function(Availability)? onAdd;
  final Function(int, Availability)? onUpdate;  
  final Function(int)? onDelete;  
  final Function? onResetMergedMessage;

  @override
  State<StatefulWidget> createState() => _AvailabilitiesListState();
}

class _AvailabilitiesListState extends State<AvailabilitiesList> with TickerProviderStateMixin {
  Widget _showAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showTitle(),
        _showAvailabilitiesList(),
        _showAddAvailabilityButton()
      ]
    );
  }

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(left: 5.0, bottom: 8.0),
      child: Text(
        'common.available_days_times'.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _showAvailabilitiesList() {
    final List<Widget> availabilityWidgets = [];
    final List<Availability>? availabilitiesList = widget.filterAvailabilities;
    if (availabilitiesList != null) {
      for (int i = 0; i < availabilitiesList.length; i++) {
        availabilityWidgets.add(AvailabilityItem(
          index: i,
          filterAvailabilities: availabilitiesList,
          mergedMessage: widget.mergedMessage,
          onUpdate: widget.onUpdate,
          onDelete: widget.onDelete,
          onResetMergedMessage: widget.onResetMergedMessage
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
      child: Wrap(
        children: availabilityWidgets
      )
    );
  }

  Widget _showAddAvailabilityButton() {  
    return Center(
      child: Container(
        height: 30.0,
        child: ElevatedButton(
          key: const Key(AppKeys.addAvailabilityBtn),
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
          ), 
          child: Text('common.add_availability'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            _showAddAvailabilityDialog();
          }
        ),
      ),
    );
  }

  void _showAddAvailabilityDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: AddAvailability(
          onAdd: widget.onAdd
        )
      ),
    ).then((shouldShowToast) {
      if (shouldShowToast == true && widget.mergedMessage?.isNotEmpty == true) {
        _showToast(context);
        _resetMergeMessage();
      }
    });     
  }

  void _resetMergeMessage() {
    if (widget.onResetMergedMessage != null) {
      widget.onResetMergedMessage!();
    }
  }

  void _showToast(BuildContext context) {
    final ScaffoldMessengerState scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        key: const Key(AppKeys.toast),
        content: Text(widget.mergedMessage as String),
        action: SnackBarAction(
          label: 'common.close'.tr(), onPressed: scaffold.hideCurrentSnackBar
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showAvailability();
  }
}