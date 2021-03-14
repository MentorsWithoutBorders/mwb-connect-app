import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/quiz_status.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/ui/views/tutorials/tutorial_view.dart';

class QuizView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<QuizView> {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  QuizzesViewModel _quizProvider;  
  final int _maxOptions = 3;
  int _selectedIndex = -1;
  bool _wasSelected = false;
  bool _closeWasPressed = false;
  String _answer;
  String _status;
  Timer _timer;
  int _timerStart = 3;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _showQuiz() {
    final int quizNumber = _storageService.quizNumber;
    final String question = 'quizzes.quiz$quizNumber.question'.tr();
    final List<String> options = [];
    for (int i = 1; i <= _maxOptions; i++) {
      final String option = 'quizzes.quiz$quizNumber.option$i'.tr();
      if (!option.contains('quizzes')) {
        options.add(option);
      }
    }
    _answer = 'quizzes.quiz$quizNumber.answer'.tr();
    final String tutorialType = 'quizzes.quiz$quizNumber.tutorial_type'.tr();
    final String tutorialSection = 'quizzes.quiz$quizNumber.tutorial_section'.tr();
    String closeWindowTimerMessage = 'quiz.close_window_timer_message'.tr();
    closeWindowTimerMessage = closeWindowTimerMessage.replaceAll('{timerStart}', _timerStart.toString());

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.fromLTRB(15.0, 30.0, 15.0, 20.0),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ALLPORTS, AppColors.EMERALD]
        )
      ),
      child: Wrap(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white
              )
            )
          ),
          Container(
            padding: const EdgeInsets.only(top: 15.0),
            child: Card(
              elevation: 3,
              child:_showOptions(options, _answer)
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Stack(
              children: <Widget>[
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                      )
                    ), 
                    onPressed: () {
                      _closeWasPressed = true;
                      _onWillPop();
                    },
                    child: Text('quiz.close'.tr(), style: const TextStyle(color: AppColors.ALLPORTS))
                  )
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(top: 9.0),
                          width: 50.0,
                          child: Text(
                            'quiz.learn_link'.tr(),
                            style: const TextStyle(
                              fontSize: 13.0,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 22.0),
                          width: 50.0,
                          child: Text(
                            'quiz.more_link'.tr() + ' >>',
                            style: const TextStyle(
                              fontSize: 13.0,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        )
                      ],
                    ),
                    onTap: () {                          
                      Navigator.push(context, MaterialPageRoute<TutorialView>(builder: (_) => TutorialView(type: tutorialType, section: tutorialSection)));
                    },                      
                  )
                )
              ],
            )
          ),
          if (_timer != null) Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Center(
              child: Text(
                _timerStart > 0 ? closeWindowTimerMessage : 'quiz.close_window_message'.tr(),
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              )
            )
          )
        ]
      )
    );
  }

  ListView _showOptions(List<String> options, String answer) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) => const Divider(
        height: 0.0,
        color: AppColors.MYSTIC,
      ),
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) => Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          color: _selectedIndex != null && _selectedIndex == index
            ? AppColors.SOLITUDE
            : Colors.white,            
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? const Radius.circular(4.0) : Radius.zero,
            topRight: index == 0 ? const Radius.circular(4.0) : Radius.zero,
            bottomLeft: index == options.length - 1 ? const Radius.circular(4.0) : Radius.zero,
            bottomRight: index == options.length - 1  ? const Radius.circular(4.0) : Radius.zero,             
          )
        ),
        child: ListTile(
          dense: true,
          title: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 40.0
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: 16.0,
                        height: 16.0,
                        decoration: BoxDecoration(
                          color: _checkCorrectAnswer(index, answer) ? Colors.greenAccent : AppColors.MYSTIC,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: _checkCorrectAnswer(index, answer) ? AppColors.TURQUOISE : AppColors.BOTTICELLI,
                            style: BorderStyle.solid
                          )
                        ),
                      ),
                      if (_checkIncorrectAnswer(index, answer)) Container (
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/images/incorrect_icon.png',
                          width: 8.0,
                          height: 8.0
                        )
                      ),
                      if (_checkCorrectAnswer(index, answer)) Container (
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/images/correct_icon.png',
                          width: 8.0,
                          height: 8.0
                        )
                      )
                    ],
                  )
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        options[index],
                      ),
                    ],
                  ),
                ),
              ]
            )
          ),
          onTap: () {
            if (_selectedIndex == -1) {
              _onSelected(index, answer);
            }
          }
        ),
      ),
    );
  }
  
  void _onSelected(int index, String answer) {
    _wasSelected = true;
    if ((index + 1).toString() == answer) {
      _quizProvider.setQuizStatus(_quizProvider.quizStatus, _storageService.quizNumber);
      _status = EnumToString.convertToString(QuizStatus.correct);
    } else {
      _status = EnumToString.convertToString(QuizStatus.incorrect);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  DateTime _getCurrentDateTime() {
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour, now.minute);    
  }

  bool _checkIncorrectAnswer(int index, String answer) {
    return _selectedIndex != -1 && index == _selectedIndex && answer != (index + 1).toString();
  }

  bool _checkCorrectAnswer(int index, String answer) {
    return _selectedIndex != -1 && answer == (index + 1).toString();
  }

  Future<bool> _onWillPop() async {
    _status ??= EnumToString.convertToString(QuizStatus.closed);
    final Quiz quiz = Quiz(number: _storageService.quizNumber, status: _status, dateTime: _getCurrentDateTime());

    if (_storageService.showQuizTimer && !_wasSelected && _timerStart > 0) {
      if (_timer == null) {
        setState(() {
          _selectedIndex = int.parse(_answer) - 1;
        });
        if (mounted) {
          startTimer();
        }
      }
      return false;
    } else {
      _timer?.cancel();
      if (_closeWasPressed) {
        _quizProvider.addQuiz(data: quiz);
        Navigator.pop(context);
      }
      _quizProvider.setQuizNumber();
      return true;
    }
  }
  
  void startTimer() {
    const Duration oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_timerStart < 1) {
            timer.cancel();
          } else {
            _timerStart = _timerStart - 1;
          }
        },
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _quizProvider = Provider.of<QuizzesViewModel>(context);    

    return WillPopScope(
      onWillPop: _onWillPop,
      child: _showQuiz()
    );
  }
}

