import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class QuizView extends StatefulWidget {
  const QuizView({Key key, @required this.quizNumber})
    : super(key: key); 
  
  final int quizNumber;

  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<QuizView> {
  QuizzesViewModel _quizProvider;
  final int _maxOptions = 3;
  int _selectedIndex = -1;
  bool _isCorrect;
  String _answer;
  bool _isAddingQuiz = false;

  Widget _showQuiz() {
    final int quizNumber = widget.quizNumber;
    final String question = 'quizzes.quiz$quizNumber.question'.tr();
    final List<String> options = [];
    for (int i = 1; i <= _maxOptions; i++) {
      final String option = 'quizzes.quiz$quizNumber.option$i'.tr();
      if (!option.contains('quizzes')) {
        options.add(option);
      }
    }
    _answer = 'quizzes.quiz$quizNumber.answer'.tr();

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.fromLTRB(15.0, 30.0, 15.0, 20.0),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)
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
                color: AppColors.DOVE_GRAY
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
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: AppColors.ALLPORTS,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                ), 
                onPressed: () async {
                  _onWillPop();
                },
                child: !_isAddingQuiz ? Text(
                  'common.close'.tr(), 
                  style: const TextStyle(color: Colors.white)
                ) : SizedBox(
                  width: 40.0,
                  height: 16.0,
                  child: ButtonLoader(),
                )
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
      physics: NeverScrollableScrollPhysics(),
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
          onTap: () async {
            if (_selectedIndex == -1) {
              await _onSelected(index, answer);
            }
          }
        ),
      ),
    );
  }
  
  Future<void> _onSelected(int index, String answer) async {
    if ((index + 1).toString() == answer) {
      _isCorrect = true;
    } else {
      _isCorrect = false;
    }    
    setState(() {
      _selectedIndex = index;
    });
    await _addQuiz();
  }

  Future<void> _addQuiz() async {
    bool isClosed = _isCorrect == null ? true : null;
    final Quiz quiz = Quiz(number: widget.quizNumber, isCorrect: _isCorrect, isClosed: isClosed);
    setState(() {
      _isAddingQuiz = true;
    });    
    await _quizProvider.addQuiz(quiz);
  }

  bool _checkIncorrectAnswer(int index, String answer) {
    return _selectedIndex != -1 && index == _selectedIndex && answer != (index + 1).toString();
  }

  bool _checkCorrectAnswer(int index, String answer) {
    return _selectedIndex != -1 && answer == (index + 1).toString();
  }

  Future<bool> _onWillPop() async {
    if (_isCorrect == null && !_isAddingQuiz) {
      await _addQuiz();
    }
    Navigator.pop(context);
    return true;
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

