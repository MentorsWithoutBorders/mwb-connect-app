import 'package:flutter/material.dart';
import 'package:mwb_connect_app/core/models/approved_user_model.dart';
import 'package:quiver/strings.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/views/forgot_password.dart';

class LoginSignupView extends StatefulWidget {
  LoginSignupView({this.auth, this.loginCallback, this.isLoginForm});

  final BaseAuth auth;
  final VoidCallback loginCallback;
  final bool isLoginForm;

  @override
  State<StatefulWidget> createState() => _LoginSignupViewState();
}

class _LoginSignupViewState extends State<LoginSignupView> {
  LocalStorageService _storageService = locator<LocalStorageService>();
  LocalizationDelegate _localizationDelegate;
  TranslateService _translator = locator<TranslateService>();  
  UserService _userService = locator<UserService>();  
  GoalsService _goalsService = locator<GoalsService>();  
  AnalyticsService _analyticsService = locator<AnalyticsService>();  
  KeyboardVisibilityNotification _keyboardVisibility = KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId;
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _email;
  String _password;
  String _errorMessage;
  bool _isLoginForm;
  bool _isLoading;
  bool _primaryButtonPressed = false;  

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
    _isLoading = false;
    _isLoginForm = widget.isLoginForm;    
  }  

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
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
            if (!_isLoginForm) _showNameInput(),
            _showEmailInput(),
            _showPasswordInput(),
            _showErrorMessage(),
            _showPrimaryButton(),
            _showSecondaryButton(),
            if (_isLoginForm) _showTertiaryButton()
          ],
        )
      )
    );
  }

//  void _showVerifyEmailSentDialog() {
//    showDialog(
//      context: context,
//      builder: (BuildContext context) {
//        // return object of type Dialog
//        return AlertDialog(
//          title: Text("Verify your account"),
//          content:
//              Text("Link to verify account has been sent to your email"),
//          actions: <Widget>[
//            FlatButton(
//              child: Text("Dismiss"),
//              onPressed: () {
//                toggleFormMode();
//                Navigator.of(context).pop();
//              },
//            ),
//          ],
//        );
//      },
//    );
//  }

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
          _isLoginForm ? _translator.getText('login.title') : _translator.getText('sign_up.title'),
          style: TextStyle(
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
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),          
          prefixIcon: Container(
            padding: const EdgeInsets.only(left: 10.0),
            child: Icon(
              Icons.person,
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
          hintText: _translator.getText('sign_up.full_name'),
          errorStyle: TextStyle(
            color: Colors.orange
          )
        ), 
        validator: (value) {
          if (_primaryButtonPressed && value.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return _translator.getText('sign_up.full_name') + ' ' + _translator.getText('login_sign_up.empty');
          } else {
            return null;
          }
        },
        onChanged: (value) {
          setState(() {
            _primaryButtonPressed = false;
            _errorMessage = '';
          });          
          Future.delayed(const Duration(milliseconds: 20), () {        
            if (value.isNotEmpty) {
              _formKey.currentState.validate();
            }
          });
        },             
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }  

  Widget _showEmailInput() {
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
          hintText: _translator.getText('login_sign_up.email'),
          errorStyle: TextStyle(
            color: Colors.orange
          )
        ), 
        validator: (value) {
          if (_primaryButtonPressed && value.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return _translator.getText('login_sign_up.email') + ' ' + _translator.getText('login_sign_up.empty');
          } else {
            return null;
          }
        },
        onChanged: (value) {
          setState(() {
            _primaryButtonPressed = false;
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

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0), 
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Icon(
              Icons.lock,
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
          hintText: _translator.getText('login_sign_up.password'),
          errorStyle: TextStyle(
            color: Colors.orange
          )
        ),
        validator: (value) {
          if (_primaryButtonPressed && value.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return _translator.getText('login_sign_up.password') + ' ' + _translator.getText('login_sign_up.empty');
          } else {
            return null;
          }          
        },
        onChanged: (value) {
          setState(() {
            _primaryButtonPressed = false;
            _errorMessage = '';
          });
          Future.delayed(const Duration(milliseconds: 20), () {
            if (value.isNotEmpty) {              
              _formKey.currentState.validate();
            }
          });
        },          
        onSaved: (value) => _password = value.trim(),
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
        child: RaisedButton(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)),
          color: Colors.white,
          child: Text(_isLoginForm ? _translator.getText('login.action') : _translator.getText('sign_up.action'),
              style: TextStyle(fontSize: 16.0, color: AppColors.ALLPORTS)),
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
            _isLoginForm ? _translator.getText('login.sign_up') : _translator.getText('sign_up.login'),
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors. white)
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
            _translator.getText('login.forgot_password'),
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors. white)
          )
        )
      ),
      onTap: _goToForgotPassword,
    );
  }

  _goToForgotPassword() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordView(auth: widget.auth)));
  }

  // Perform login or sign_up
  Future _validateAndSubmit() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_isLoginForm) {
          userId = await widget.auth.signIn(_email, _password);
          await _setUserStorage(userId: userId, email: _email);
          print('Signed in: $userId');
        } else {
          await _signInAnonymously();
          ApprovedUser approvedUser = await _userService.checkApprovedUser(_email);
          if (approvedUser != null) {
            userId = await widget.auth.signUp(_name, _email, _password);
            //widget.auth.sendEmailVerification();
            //_showVerifyEmailSentDialog();
            await _setUserStorage(userId: userId, name: _name, email: _email);
            _addUser(approvedUser);          
            print('Signed up user: $userId');
          } else {
            throw Exception(_translator.getText('sign_up.not_approved'));
          }
        }
        setState(() {
          _isLoading = false;
        });

        if (isNotEmpty(userId)) {
          _identifyUser();
          Navigator.pop(context);
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    }
  }

  // Check if form is valid before performing login or sign_up
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future _signInAnonymously() async {
    await widget.auth.signInAnonymously();
  }  

  Future _setUserStorage({String userId, String name, String email}) async {
    User user = User(id: userId, name: name, email: email);
    await _userService.setUserStorage(user: user);
  }

  void _addUser(ApprovedUser approvedUser) async {
    DateTime now = DateTime.now();
    User defaultUser = await _userService.getDefaultUserDetails();
    User user = User(id: approvedUser.id, name: approvedUser.name, email: approvedUser.email, isMentor: approvedUser.isMentor, 
        organization: approvedUser.organization, field: approvedUser.field, subFields: approvedUser.subFields, 
        availability: defaultUser.availability, registeredOn: now);
    if (approvedUser.isMentor) {
      user.isAvailable = defaultUser.isAvailable;
      user.lessonsAvailability = defaultUser.lessonsAvailability;
    }
    _userService.setUserDetails(user);
    if (!approvedUser.isMentor && isNotEmpty(approvedUser.goal)) {
      _addGoal(approvedUser.goal);
    }
  }

  void _addGoal(String goalText) {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);    
    Goal goal = Goal(text: goalText, index: 0, dateTime: dateTime);
    _goalsService.addGoal(goal);
  }

  void _identifyUser() {
    String userId = _storageService.userId;
    String name = _storageService.userName;
    String email = _storageService.userEmail;
    _analyticsService.identifyUser(userId, name, email);
  }  

  void _resetForm() {
    _formKey.currentState.reset();
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
    _localizationDelegate = LocalizedApp.of(context).delegate;
    _translator.localizationDelegate = _localizationDelegate;

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
              if (_isLoading) Loader()
            ],
          )
        )
      ],
    );
  }  
}
