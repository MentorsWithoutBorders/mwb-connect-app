import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/error_model.dart';
import 'package:mwb_connect_app/core/viewmodels/login_signup_view_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/views/forgot_password_view.dart';

class LoginSignupView extends StatefulWidget {
  const LoginSignupView({Key? key, this.loginCallback, required this.isLoginForm})
    : super(key: key); 

  final VoidCallback? loginCallback;
  final bool isLoginForm;

  @override
  State<StatefulWidget> createState() => _LoginSignupViewState();
}

class _LoginSignupViewState extends State<LoginSignupView> {
  LoginSignupViewModel? _loginSignupProvider;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User? _user;
  String? _name;
  String? _email;
  String? _password;
  String? _errorMessage;
  bool _isLoginForm = true;
  bool _isLoading = false;
  bool? _primaryButtonPressed = false;  

  @override
  @protected
  void initState() {
    super.initState();
    KeyboardVisibilityController keyboardVisibilityController = KeyboardVisibilityController();
    WidgetsBinding.instance.addPostFrameCallback((_) {    
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
    });
    _isLoading = false;
    _isLoginForm = widget.isLoginForm;    
  }  

  Widget _showForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            _showLogo(),
            _showTitle(),
            if (_isLoginForm == false) _showNameInput(),
            _showEmailInput(),
            _showPasswordInput(),
            _showErrorMessage(),
            _showPrimaryButton(),
            _showSecondaryButton(),
            if (_isLoginForm == true) _showTertiaryButton()
          ],
        )
      )
    );
  }

  Widget _showLogo() {
    return Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/images/logo.png'),
      ),
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Center(
        child: Text(
          _isLoginForm == true ? 'login.title'.tr() : 'sign_up.title'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22.0,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        )
      )
    );
  }

  Widget _showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15.0
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),          
          prefixIcon: Container(
            padding: const EdgeInsets.only(left: 10.0, bottom: 3.0),
            child: const Icon(
              Icons.person,
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
          hintText: 'sign_up.full_name'.tr(),
          errorStyle: const TextStyle(
            fontSize: 13.0,
            color: AppColors.SOLITUDE,
            height: 1.0,
            fontWeight: FontWeight.w400
          )
        ), 
        validator: (String? value) {
          if (_primaryButtonPressed == true && value?.isEmpty == true) {
            setState(() {
              _isLoading = false;
            });
            return 'sign_up.full_name'.tr() + ' ' + 'login_sign_up.empty'.tr();
          } else {
            return null;
          }
        },
        onChanged: (String value) {
          setState(() {
            _primaryButtonPressed = false;
            _errorMessage = '';
          });          
          Future<void>.delayed(const Duration(milliseconds: 20), () {        
            if (value.isNotEmpty) {
              _formKey.currentState?.validate();
            }
          });
        },             
        onSaved: (String? value) => _name = value?.trim(),
      ),
    );
  }  

  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: TextFormField(
        key: const Key(AppKeys.loginEmailField),
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
          hintText: 'login_sign_up.email'.tr(),
          errorStyle: const TextStyle(
            fontSize: 13.0,
            color: AppColors.SOLITUDE,
            height: 1.0,
            fontWeight: FontWeight.w400
          )
        ), 
        validator: (String? value) {
          if (_primaryButtonPressed == true && value?.isEmpty == true) {
            setState(() {
              _isLoading = false;
            });
            return 'login_sign_up.email'.tr() + ' ' + 'login_sign_up.empty'.tr();
          } else {
            return null;
          }
        },
        onChanged: (String value) {
          setState(() {
            _primaryButtonPressed = false;
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

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: TextFormField(
        key: const Key(AppKeys.loginPasswordField),
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15.0
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0), 
          prefixIcon: Container(
            padding: EdgeInsets.only(left: 10.0, bottom: 3.0),
            child: Icon(
              Icons.lock,
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
          hintText: 'login_sign_up.password'.tr(),
          errorStyle: const TextStyle(
            fontSize: 13.0,
            color: AppColors.SOLITUDE,
            height: 1.0,
            fontWeight: FontWeight.w400
          )
        ),
        validator: (String? value) {
          if (_primaryButtonPressed == true && value?.isEmpty == true) {
            setState(() {
              _isLoading = false;
            });
            return 'login_sign_up.password'.tr() + ' ' + 'login_sign_up.empty'.tr();
          } else {
            return null;
          }          
        },
        onChanged: (String value) {
          setState(() {
            _primaryButtonPressed = false;
            _errorMessage = '';
          });
          Future<void>.delayed(const Duration(milliseconds: 20), () {
            if (value.isNotEmpty) {              
              _formKey.currentState?.validate();
            }
          });
        },          
        onSaved: (String? value) => _password = value?.trim(),
      ),
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage?.isNotEmpty == true && _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 15.0),
        child: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(
              fontSize: 13.0,
              color: AppColors.SOLITUDE,
              height: 1.0,
              fontWeight: FontWeight.w400
            ),
          )
        )
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }  

  Widget _showPrimaryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
      child: SizedBox(
        height: 42.0,
        child: ElevatedButton(
          key: const Key(AppKeys.loginSignupPrimaryBtn),
          style: ElevatedButton.styleFrom(
            elevation: 2.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)
            )
          ),  
          child: Text(_isLoginForm == true ? 'login.action'.tr() : 'sign_up.action'.tr(),
              style: const TextStyle(fontSize: 16.0, color: AppColors.ALLPORTS)),
          onPressed: () async {
            setState(() {
              _primaryButtonPressed = true;
            });
            await _validateAndSubmit();
          }
        ),
      )
    );
  }  

  Widget _showSecondaryButton() {
    return InkWell(
      child: Center(
        child: Container(
          height: 30.0,
          margin: const EdgeInsets.only(top: 15.0),
          child: Text(
            _isLoginForm == true ? 'login.sign_up'.tr() : 'sign_up.login'.tr(),
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors. white)
          )
        )
      ),
      onTap: _toggleFormMode,
    );
  }

  Widget _showTertiaryButton() {
    return InkWell(
      child: Center(
        child: Container(
          height: 30.0,
          margin: const EdgeInsets.only(top: 10.0),
          child: Text(
            'login.forgot_password'.tr(),
            style: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors. white)
          )
        )
      ),
      onTap: _goToForgotPassword,
    );
  }

  void _goToForgotPassword() {
    Navigator.push(context, MaterialPageRoute<ForgotPasswordView>(builder: (_) => ForgotPasswordView()));
  }

  // Perform login or sign_up
  Future<void> _validateAndSubmit() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String? userId = '';
      try {
        if (_isLoginForm == true) {
          _user = User(email: _email, password: _password);
          userId = await _loginSignupProvider?.login(_user!);
          print('Signed in: $userId');
        } else {
          _user = User(name: _name, email: _email, password: _password);
          userId = await _loginSignupProvider?.signUp(_user!);
        }
        setState(() {
          _isLoading = false;
        });

        if (isNotEmpty(userId)) {
          Navigator.pop(context);
          widget.loginCallback!();
        }
      } on ErrorModel catch (error) {
        String message = 'common.try_again'.tr();
        if (error.message != null) {
          message = error.message as String;
        }
        setState(() {
          _isLoading = false;
          _errorMessage = message;
        });
      }
    }
  }

  // Check if form is valid before performing login or sign_up
  bool _validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form?.validate() == true) {
      form?.save();
      return true;
    }
    return false;
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _errorMessage = '';
  }

  void _toggleFormMode() {
    _resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }   

  @override
  Widget build(BuildContext context) {
    _loginSignupProvider = Provider.of<LoginSignupViewModel>(context);

    return Stack(
      children: <Widget>[
        BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,          
            elevation: 0.0,
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: <Widget>[
              _showForm(),
              if (_isLoading == true) Loader()
            ],
          )
        )
      ],
    );
  }  
}
