import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({Key? key, this.logoutCallback})
    : super(key: key);

  final VoidCallback? logoutCallback;

  @override
  State<StatefulWidget> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  ProfileViewModel? _profileProvider;

  Widget _showDeleteAccountDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    String title = 'profile.delete_account'.tr();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    String text = 'profile.delete_account_text'.tr();

    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.0,
          color: AppColors.DOVE_GRAY,
          height: 1.5
        )
      )
    );
  }
  
  Widget _showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
            child: Text('common.no_abort'.tr(), style: const TextStyle(color: Colors.grey))
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          child: Text(
            'common.yes_delete'.tr(),
            style: const TextStyle(color: Colors.white)
          ),
          onPressed: () {
            Navigator.pop(context, true);
            _deleteAccount();
          },
        )
      ]
    );
  } 

  Future<void> _deleteAccount() async {  
    _profileProvider?.deleteUser();
    widget.logoutCallback!();
  }
  
  @override
  Widget build(BuildContext context) {
    _profileProvider = Provider.of<ProfileViewModel>(context);

    return _showDeleteAccountDialog();
  }
}