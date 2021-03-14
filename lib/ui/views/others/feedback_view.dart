import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/feedback_model.dart';
import 'package:mwb_connect_app/core/viewmodels/feedback_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({Key key, this.auth})
    : super(key: key);   

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final PageController _controller = PageController(viewportFraction: 1, keepPage: true);
  final KeyboardVisibilityNotification _keyboardVisibility = KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  String _feedbackText;
  bool _sendButtonPressed = false;

  @override
  @protected
  void initState() {
    super.initState();
    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        if (visible) {
          Future<void>.delayed(const Duration(milliseconds: 100), () {
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
            'feedback.label'.tr(),
            style: const TextStyle(
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
            hintText: 'feedback.message_placeholder'.tr()
          ), 
          validator: (String value) {
            if (_sendButtonPressed && value.isEmpty) {
              return 'feedback.message_error'.tr();
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
                _formKey.currentState.validate();
              }
            });
          },             
          onSaved: (String value) => _feedbackText = value.trim(),
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
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)
            ),
            padding: const EdgeInsets.fromLTRB(50.0, 12.0, 50.0, 12.0)
          ), 
          child: Text(
            'feedback.send'.tr(),
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
        _sendFeedback(_feedbackText);
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  // Check if form is valid
  bool _validateAndSave() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  
  Future<void> _sendFeedback(String text) async {
    final FeedbackViewModel feedbackViewModel = locator<FeedbackViewModel>();
    final FeedbackModel feedback = FeedbackModel(
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease
    );
  }   

  Widget _showConfirmation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25.0, 120.0, 25.0, 0.0),
      child: Text(
        'feedback.confirmation'.tr(),
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
        child: Text('feedback.title'.tr()),
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
          body: _showFeedback(context)
        )
      ],
    );
  }  
}
