import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/support_request_model.dart';
import 'package:mwb_connect_app/core/viewmodels/support_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class SupportView extends StatefulWidget {
  const SupportView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  final PageController _controller = PageController(viewportFraction: 1, keepPage: true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  String? _supportText;
  bool _sendButtonPressed = false;

  @override
  @protected
  void initState() {
    super.initState();
    KeyboardVisibilityController keyboardVisibilityController = KeyboardVisibilityController();   
    keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible && _scrollController.hasClients) {
        Future<void>.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _showSupport() {
    return Container(
      height: double.infinity,
      child: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          _showForm(),
          _showConfirmation()
        ],
      )
    );
  }  

  Widget _showForm() {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            _showSupportTitle(),
            _showInput(),
            _showSendButton()
          ],
        )
      )
    );
  }

  Widget _showSupportTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          Text(
            'support.label'.tr(),
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              'support.sub_label'.tr(),
              style: const TextStyle(
                fontSize: 12.0,
                color: Colors.white
              ),
            ) 
          )
        ],
      )
    );
  }

  Widget _showInput() {
    return Container(
      height: 150.0,
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: Card(
        elevation: 3,
        child: TextFormField(
          maxLines: null,
          style: const TextStyle(
            fontSize: 15.0
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),          
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintStyle: const TextStyle(color: AppColors.SILVER),
            hintText: 'support.message_placeholder'.tr(),
          ), 
          validator: (String? value) {
            if (_sendButtonPressed && value?.isEmpty == true) {
              return 'support.message_error'.tr();
            } else {
              return null;
            }
          },
          onChanged: (String value) {
            setState(() {
              _sendButtonPressed = false;
            });          
            Future<void>.delayed(const Duration(milliseconds: 20), () {        
              if (value.isNotEmpty) {
                _formKey.currentState?.validate();
              }
            });
          },             
          onSaved: (String? value) => _supportText = value?.trim(),
        ),
      ),
    );
  }

  Widget _showSendButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 30.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 2.0,
            backgroundColor: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)
            ),
            padding: const EdgeInsets.fromLTRB(40.0, 12.0, 40.0, 12.0)
          ), 
          child: Text(
            'common.send_request'.tr(),
            style: const TextStyle(fontSize: 16.0, color: Colors.white)
          ),
          onPressed: () async {
            setState(() {
              _sendButtonPressed = true;
            });
            _validateAndSubmit();
          }
        )
      ),
    );
  }
  
  Future<void> _validateAndSubmit() async {
    if (_validateAndSave()) {
      try {
        // Just a delay effect for the send request
        await Future<void>.delayed(const Duration(milliseconds: 300));
        _sendRequest(_supportText);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  // Check if form is valid
  bool _validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form?.validate() == true) {
      form?.save();
      return true;
    }
    return false;
  }
  
  void _sendRequest(String? text) {
    final SupportRequestViewModel supportRequestProvider = locator<SupportRequestViewModel>();
    final SupportRequest supportRequest = SupportRequest(
      text: text
    );
    supportRequestProvider.addSupportRequest(supportRequest);
    _goToConfirmation();
  }

 void _goToConfirmation() {
    FocusScope.of(context).unfocus();
    int page = _controller.page?.toInt() as int;
    _controller.animateToPage(page + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease
    );
  }   

  Widget _showConfirmation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 120.0, 25.0, 0.0),
      child: Text(
        'support.confirmation'.tr(),
        style: const TextStyle(
          fontSize: 14.0,
          color: Colors.white
        ),
      ),
    );
  }   

  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'support.title'.tr(),
          textAlign: TextAlign.center
        )
      )
    );
  }   

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        BackgroundGradient(),
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
          body: _showSupport()
        )
      ],
    );
  }  
}
