import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/quiz_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';

class QuizView extends StatefulWidget {
  const QuizView({Key? key})
    : super(key: key); 
  
  @override
  State<StatefulWidget> createState() => _QuizState();
}

class _QuizState extends State<QuizView> {
  QuizzesViewModel? _quizzesProvider;
  final ScrollController _scrollController = ScrollController();
  int _quizNumber = 1;
  int _nextQuizNumber = 1;
  final int _maxOptions = 3;
  int _selectedIndex = -1;
  String? _answer;
  bool? _isCorrect;
  bool _shouldShowNextButton = false;
  bool _shouldShowTryAgainButton = false;
  bool _shouldShowCompletedMessage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_initQuizNumber);
  }  

  void _initQuizNumber(_) {
    _quizzesProvider!.calculateQuizNumber();
    _quizzesProvider!.calculateQuizNumberIndex();
    setState(() {
      _quizNumber = _quizzesProvider!.quizNumber;
    });
  }    

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }    

  Widget _showQuiz() {
    final bool isMentor = _quizzesProvider?.isMentor ?? false;
    final int index = _quizzesProvider?.quizNumberIndex ?? 1;
    final int quizzesCount = _quizzesProvider?.quizzes.length ?? 1;
    final String type = isMentor ? 'mentors' : 'students';
    final String quizTutorialTitle = 'quiz_tutorials.$type.quiz_tutorial$_quizNumber.title'.tr();
    final String quizTutorialText = 'quiz_tutorials.$type.quiz_tutorial$_quizNumber.text'.tr();
    final String question = 'quizzes.$type.quiz$_quizNumber.question'.tr();
    final List<String> options = [];
    for (int i = 1; i <= _maxOptions; i++) {
      final String option = 'quizzes.$type.quiz$_quizNumber.option$i'.tr();
      if (!option.contains('quizzes')) {
        options.add(option);
      }
    }
    _answer = 'quizzes.$type.quiz$_quizNumber.answer'.tr();

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0)
        )
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
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
                          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1.0, color: AppColors.MYSTIC)
                            ),
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Center(
                            child: Text(
                              'quizzes.quiz_of'.tr(args: [index.toString(), quizzesCount.toString()]),
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: AppColors.BERMUDA_GRAY
                              )
                            ),
                          )
                        ), 
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
                          child: Text(
                            question,
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: AppColors.ALLPORTS,
                              fontWeight: FontWeight.bold
                            )
                          )
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.MYSTIC)
                          ),
                          child: _showOptions(options, _answer!)
                        ),
                        if (_shouldShowNextButton == true) _showNextButton(),
                        if (_shouldShowTryAgainButton == true) _showTryAgainButton(),
                        if (_shouldShowCompletedMessage == true) _showCompletedMessage(),
                      ]
                    ),
                  )
                )
              )
            )
          ),
          _showCloseButton()
        ],
      )
    );
  }

  Widget _showNextButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
      child: Center(
        child: Container(
          height: 30.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.PACIFIC_BLUE,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(35.0, 0.0, 35.0, 0.0),
            ), 
            onPressed: () async {
              _showNextQuiz();
            },
            child: Text(
              'quizzes.next_quiz'.tr(), 
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.white
              )
            )
          ),
        )
      ),
    );
  }

  void _showNextQuiz() {
    setState(() {
      _selectedIndex = -1;
      _shouldShowNextButton = false;
      _quizNumber = _nextQuizNumber;
    });
    _quizzesProvider!.calculateQuizNumberIndex();
    _scrollToTop();
  }

  Future<void> _scrollToTop() async {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );    
  }      

  Widget _showTryAgainButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
      child: Center(
        child: Container(
          height: 30.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.PACIFIC_BLUE,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(35.0, 0.0, 35.0, 0.0),
            ), 
            onPressed: () async {
              _showSameQuiz();
            },
            child: Text(
              'quizzes.try_again'.tr(), 
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.white
              )
            )
          ),
        )
      ),
    );
  }
  
  void _showSameQuiz() {
    setState(() {
      _selectedIndex = -1;
      _shouldShowTryAgainButton = false;
    });
    _scrollToTop();
  }  

  Widget _showCompletedMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
            child: Text(
              'quizzes.quizzes_solved'.tr(),
              style: const TextStyle(
                fontSize: 12.0,
                color: AppColors.ALLPORTS,
                height: 1.3
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center
            ),
          ),
        ],
      ),
    );
  }

  Widget _showCloseButton() {
    return Center(
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
          color: _selectedIndex == index
            ? AppColors.SOLITUDE
            : Colors.white 
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
                          color: _selectedIndex == index && _checkCorrectAnswer(index, answer) ? Colors.greenAccent : AppColors.MYSTIC,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 1,
                            color: _selectedIndex == index && _checkCorrectAnswer(index, answer) ? AppColors.TURQUOISE : AppColors.BOTTICELLI,
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
                      if (_selectedIndex == index && _checkCorrectAnswer(index, answer)) Container (
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
    _addQuiz();
    await _scrollToBottom();
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );    
  }   

  void _addQuiz() {
    bool? isClosed = _isCorrect == null ? true : null;
    if (_quizNumber != 0) {
      final Quiz quiz = Quiz(number: _quizNumber, isCorrect: _isCorrect, isClosed: isClosed);
      if (_isCorrect == false) {
        _setShowTryAgainButton(true);
        _quizzesProvider?.addQuiz(quiz);
      } else {
        _nextQuizNumber = _quizzesProvider?.addQuiz(quiz) as int;
        if (mounted) {
          if (quiz.isClosed != true) {
            if (_nextQuizNumber != 0) {
              _setShowNextButton(true);
            } else {
              _setShowCompletedMessage(true);
            }
          } else {
            _setShowNextButton(false);
            _setShowTryAgainButton(false);
            _setShowCompletedMessage(false);
          }
        }
      }
    }
  }

  void _setShowNextButton(bool shouldShowNextButton) {
    setState(() {
      _shouldShowNextButton = shouldShowNextButton;
    });   
  }

  void _setShowTryAgainButton(bool shouldShowTryAgainButton) {
    setState(() {
      _shouldShowTryAgainButton = shouldShowTryAgainButton;
    });   
  }  

  void _setShowCompletedMessage(bool shouldShowCompletedMessage) {
    setState(() {
      _shouldShowCompletedMessage = shouldShowCompletedMessage;
    });   
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
    _quizzesProvider = Provider.of<QuizzesViewModel>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: _showQuiz()
    );
  }
}

