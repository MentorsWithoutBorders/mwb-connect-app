import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class ForgotPasswordView extends StatefulWidget {
  ForgotPasswordView({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  PageController _controller = PageController(viewportFraction: 1, keepPage: true);
  KeyboardVisibilityNotification _keyboardVisibility = KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  String _email;
  String _errorMessage;
  bool _changeButtonPressed = false;

  @protected
  void initState() {
    super.initState();
    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        if (visible) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
          });
        }
      },
    );
    _errorMessage = '';
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
  }

  Widget _showForgotPassword(BuildContext context) {
    return Container(
      height: double.infinity,
      child: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
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
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              'forgot_password.link_label'.tr(),
              style: TextStyle(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),          
          prefixIcon: Container(
            padding: const EdgeInsets.only(left: 10.0),
            child: Icon(
              Icons.mail,
              color: Colors.white,
              size: 18.0
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              color: Colors.white
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              color: Colors.white
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              color: Colors.white
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              color: Colors.white
            ),
          ),
          hintStyle: TextStyle(color: Colors.white),
          hintText: 'forgot_password.email'.tr(),
          errorStyle: TextStyle(
            color: Colors.orange
          )
        ), 
        validator: (value) {
          if (_changeButtonPressed && value.isEmpty) {
            return 'forgot_password.email_empty'.tr();
          } else {
            return null;
          }
        },
        onChanged: (value) {
          setState(() {
            _changeButtonPressed = false;
            _errorMessage = '';
          });          
          Future.delayed(const Duration(milliseconds: 20), () {        
            if (value.isNotEmpty) {
              _formKey.currentState.validate();
            }
          });
        },             
        onSaved: (value) => _email = value.trim(),
      ),
    );
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 20.0),
        child: Center(
          child: Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.orange,
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

  Widget _showChangeButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 30.0),
      child: SizedBox(
        height: 42.0,
        child: RaisedButton(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0)),
          color: Colors.white,
          child: Text(
            'forgot_password.next'.tr(),
            style: TextStyle(fontSize: 16.0, color: AppColors.ALLPORTS)
          ),
          onPressed: () async {
            if (!_changeButtonPressed) {
              setState(() {
                _changeButtonPressed = true;
              });
              _validateAndSubmit();
            }
          }
        ),
      )
    );
  }
  
  void _validateAndSubmit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = '';
    });
    if (_validateAndSave()) {
      try {
        await _resetPassword(_email);
      } catch (e) {
        print('Error: $e');
        setState(() {
          _errorMessage = e.message;
        });
      }
    }
  }

  // Check if form is valid
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  
  Future<void> _resetPassword(String email) async {
    await widget.auth.sendPasswordResetEmail(email);
    _goToConfirmation();
  }

 void _goToConfirmation() {
    _controller.animateToPage(_controller.page.toInt() + 1,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease
    );
  }   

  Widget _showConfirmation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 120.0, 25.0, 0.0),
      child: Text(
        'forgot_password.email_sent'.tr(),
        style: TextStyle(
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
        child: Text('forgot_password.title'.tr()),
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
              icon: Icon(Icons.close),
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
