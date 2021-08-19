import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';

class QuizView extends StatefulWidget {
  const QuizView({Key key, @required this.quizNumber})
    : super(key: key); 
  
  final int quizNumber;

  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<QuizView> {
  QuizzesViewModel _quizProvider;
  final ScrollController _scrollController = ScrollController();  
  final int _maxOptions = 3;
  int _selectedIndex = -1;
  bool _isCorrect;
  String _answer;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }    

  Widget _showQuiz() {
    final bool isMentor = _quizProvider.isMentor ?? false;
    final String type = isMentor ? 'mentors' : 'students';
    final int quizNumber = widget.quizNumber;
    final String quizTutorialTitle = 'quiz_tutorials.$type.quiz_tutorial$quizNumber.title'.tr();
    final String quizTutorialText = 'quiz_tutorials.$type.quiz_tutorial$quizNumber.text'.tr();
    final String question = 'quizzes.$type.quiz$quizNumber.question'.tr();
    final List<String> options = [];
    for (int i = 1; i <= _maxOptions; i++) {
      final String option = 'quizzes.$type.quiz$quizNumber.option$i'.tr();
      if (!option.contains('quizzes')) {
        options.add(option);
      }
    }
    _answer = 'quizzes.$type.quiz$quizNumber.answer'.tr();

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.fromLTRB(15.0, 30.0, 15.0, 20.0),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)
        )
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Wrap(
              children: [
                Center(
                  child: Text(
                    quizTutorialTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.ALLPORTS,
                      fontWeight: FontWeight.bold,
                      height: 1.8
                    )
                  )
                ),
                Center(
                  child: Text(
                    'quizzes.solve_quiz_subtitle'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.DOVE_GRAY
                    )
                  )
                ) 
              ]
            )
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Scrollbar(
                controller: _scrollController, 
                isAlwaysShown: true, 
                child: SingleChildScrollView(
                  controller: _scrollController,                
                  child: Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 20.0),
                          child: HtmlWidget(quizTutorialText)
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1.0, color: AppColors.MYSTIC)
                            ),
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
                          child: Text(
                            question,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.ALLPORTS,
                              fontWeight: FontWeight.bold
                            )
                          )
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
                          padding: const EdgeInsets.fromLTRB(0.0, 5.0, 10.0, 5.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.MYSTIC)
                          ),
                          child: _showOptions(options, _answer)
                        )
                      ]
                    ),
                  )
                )
              )
            )
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: AppColors.BERMUDA_GRAY,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                ),
                padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
              ), 
              onPressed: () async {
                _closeDialog();
              },
              child: Text(
                'common.close'.tr(), 
                style: const TextStyle(color: Colors.white)
              )
            )
          )
        ],
      )
    );
  }

  ListView _showOptions(List<String> options, String answer) {
    return ListView.separated(
      padding: const EdgeInsets.all(0),
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
                Padding(
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
    await _quizProvider.addQuiz(quiz);
  }

  bool _checkIncorrectAnswer(int index, String answer) {
    return _selectedIndex != -1 && index == _selectedIndex && answer != (index + 1).toString();
  }

  bool _checkCorrectAnswer(int index, String answer) {
    return _selectedIndex != -1 && answer == (index + 1).toString();
  }

  void _closeDialog() {
    if (_isCorrect == null) {
      _addQuiz();
    }
    Navigator.pop(context);
  }

  Future<bool> _onWillPop() async {
    _closeDialog();
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

