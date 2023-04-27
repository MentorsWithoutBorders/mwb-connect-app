import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/error_model.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/forgot_password_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final PageController _controller = PageController(viewportFraction: 1, keepPage: true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  String? _email;
  String? _errorMessage;
  bool _changeButtonPressed = false;

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
    _errorMessage = '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _showForgotPassword(BuildContext context) {
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
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            _showLogo(),
            _showEmailTitle(),
            _showInput(),
            _showErrorMessage(),
            _showChangeButton()
          ],
        )
      )
    );
  }

  Widget _showLogo() {
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 48.0,
      child: Image.asset('assets/images/forgot_password.png'),
    );
  }

  Widget _showEmailTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          Text(
            'forgot_password.email_label'.tr(),
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              'forgot_password.link_label'.tr(),
              style: const TextStyle(
                fontSize: 13.0,
                color: Colors.white
              ),
            ) 
          )
        ],
      )
    );
  }

  Widget _showInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15.0
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),          
          prefixIcon: Container(
            padding: const EdgeInsets.only(left: 10.0, bottom: 3.0),
            child: const Icon(
              Icons.mail,
              color: Colors.white,
              size: 18.0
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(
              color: Colors.white
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(
              color: Colors.white
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(
              color: Colors.white
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(
              color: Colors.white
            ),
          ),
          hintStyle: const TextStyle(color: Colors.white),
          hintText: 'forgot_password.email'.tr(),
          errorStyle: const TextStyle(
            color: AppColors.SOLITUDE
          )
        ), 
        validator: (String? value) {
          if (value?.isEmpty == true) {
            return 'forgot_password.email_not_valid'.tr();
          } else {
            return null;
          }
        },
        onChanged: (String value) {
          setState(() {
            _changeButtonPressed = false;
            _errorMessage = '';
          });          
          Future<void>.delayed(const Duration(milliseconds: 20), () {        
            if (value.isNotEmpty) {
              _formKey.currentState?.validate();
            }
          });
        },             
        onSaved: (String? value) => _email = value?.trim(),
      ),
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage?.isNotEmpty == true && _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 20.0),
        child: Text(
          _errorMessage!,
          style: const TextStyle(
            fontSize: 13.0,
            color: AppColors.SOLITUDE,
            height: 1.0,
            fontWeight: FontWeight.w400
          ),
        )
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }  

  Widget _showChangeButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 30.0),
      child: SizedBox(
        height: 42.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 2.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)
            ),
          ),
          onPressed: () async {
            if (!_changeButtonPressed) {
              await _validateAndSubmit();
            }
          },
          child: !_changeButtonPressed ? Text(
            'forgot_password.next'.tr(),
            style: const TextStyle(color: AppColors.ALLPORTS)
          ) : SizedBox(
            width: 80.0,
            height: 20.0,
            child: ButtonLoader(color: AppColors.ALLPORTS)
          )
        ),
      )
    );
  }
  
  Future<void> _validateAndSubmit() async {
    FocusScope.of(context).unfocus();
    _setErrorMessage('');
    if (_validateAndSave()) {
      try {
        await _resetPassword(_email!);
      } on ErrorModel catch (e) {
        print('Error: $e');
        _setErrorMessage(e.message);
      }
    }
  }

  void _setErrorMessage(String? error) {
    setState(() {
      _errorMessage = error;
    });    
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
  
  Future<void> _resetPassword(String email) async {
    setState(() {
      _changeButtonPressed = true;
    });    
    final ForgotPasswordViewModel forgotPasswordProvider = locator<ForgotPasswordViewModel>();
    await forgotPasswordProvider.sendResetPassword(email);
    _goToConfirmation();
  }

 void _goToConfirmation() {
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
        'forgot_password.email_sent'.tr(),
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
          'forgot_password.title'.tr(),
          textAlign: TextAlign.center
        ),
      )
    );
  }   

  @override
  Widget build(BuildContext context) {
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
          body: _showForgotPassword(context)
        )
      ],
    );
  }  
}
