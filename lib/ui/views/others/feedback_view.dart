import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/models/feedback_model.dart';
import 'package:mwb_connect_app/core/viewmodels/feedback_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class FeedbackView extends StatefulWidget {
  FeedbackView({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  LocalizationDelegate _localizationDelegate;
  LocalStorageService _storageService = locator<LocalStorageService>();
  TranslateService _translator = locator<TranslateService>();
  PageController _controller = PageController(viewportFraction: 1, keepPage: true);
  KeyboardVisibilityNotification _keyboardVisibility = KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  String _feedbackText;
  bool _sendButtonPressed = false;

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
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
  }

  Widget _showFeedback(BuildContext context) {
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
      padding: const EdgeInsets.all(5.0),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          children: <Widget>[
            _showFeedbackTitle(),
            _showInput(),
            _showSendButton()
          ],
        )
      )
    );
  }

  Widget _showFeedbackTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          Text(
            _translator.getText('feedback.label'),
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white
            ),
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
          style: TextStyle(
            fontSize: 15.0
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),          
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.SILVER),
            hintText: _translator.getText('feedback.message_placeholder')
          ), 
          validator: (value) {
            if (_sendButtonPressed && value.isEmpty) {
              return _translator.getText('feedback.message_error');
            } else {
              return null;
            }
          },
          onChanged: (value) {
            setState(() {
              _sendButtonPressed = false;
            });          
            Future.delayed(const Duration(milliseconds: 20), () {        
              if (value.isNotEmpty) {
                _formKey.currentState.validate();
              }
            });
          },             
          onSaved: (value) => _feedbackText = value.trim(),
        ),
      ),
    );
  }

  Widget _showSendButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 30.0),
        child: RaisedButton(
          elevation: 2.0,
          padding: const EdgeInsets.fromLTRB(50.0, 12.0, 50.0, 12.0),
          splashColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0)
          ),
          color: AppColors.MONZA,
          child: Text(
            _translator.getText('feedback.send'),
            style: TextStyle(fontSize: 16.0, color: Colors.white)
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
  
  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      try {
        // Just a delay effect for the send request
        await Future.delayed(const Duration(milliseconds: 300));
        _sendFeedback(_feedbackText);
      } catch (e) {
        print('Error: $e');
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
  
  Future<void> _sendFeedback(String text) async {
    FeedbackViewModel feedbackViewModel = locator<FeedbackViewModel>();
    FeedbackModel feedback = FeedbackModel(
      text: text,
      userId: _storageService.userId,
      userEmail: _storageService.userEmail,
      userName: _storageService.userName,
      dateTime: DateTime.now()
    );
    feedbackViewModel.addFeedback(feedback);
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
        _translator.getText('feedback.confirmation'),
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
        child: Text(_translator.getText('feedback.title')),
      )
    );
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
            title: _showTitle(),
            backgroundColor: Colors.transparent,          
            elevation: 0.0,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(null),
            )
          ),
          extendBodyBehindAppBar: true,
          body: _showFeedback(context)
        )
      ],
    );
  }  
}
