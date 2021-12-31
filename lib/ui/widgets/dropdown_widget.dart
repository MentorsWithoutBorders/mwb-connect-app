import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class Dropdown<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>>? dropdownMenuItemList;
  final VoidCallback? onTapped;
  final ValueChanged<T?>? onChanged;
  final T? value;

  Dropdown({
    Key? key,
    @required this.dropdownMenuItemList,
    this.onTapped,
    @required this.onChanged,
    @required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10.0, right: 5.0),      
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        border: Border.all(
          color: AppColors.SILVER,
          width: 1,
        ),
        color: Colors.white
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          key: key,
          isExpanded: true,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black
          ),
          items: dropdownMenuItemList,
          onChanged: onChanged,
          onTap: onTapped,
          value: value,
        ),
      ),
    );
  }
}
