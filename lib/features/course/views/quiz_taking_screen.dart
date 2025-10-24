import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/course/models/chapter.dart';
import '../../../../features/course/models/quiz.dart';
import '../../../../features/course/services/quiz_service.dart';
import 'quiz_result_screen.dart';

class QuizTakingScreen extends StatefulWidget {
  final Quiz quiz;
  final Lesson lesson;

  const QuizTakingScreen({
    super.key,
    required this.quiz,
    required this.lesson,
  });

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  final QuizService _quizService = QuizService();
  
  int _currentQuestionIndex = 0;
  Map<String, String> _selectedAnswers = {}; // For single choice and true/false
  Map<String, Set<String>> _multipleSelectedAnswers = {}; // For multiple choice
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.quiz.timeLimit * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _submitQuiz();
        }
      });
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
      _multipleSelectedAnswers.clear();
      _remainingSeconds = widget.quiz.timeLimit * 60;
      _isSubmitted = false;
      _isSubmitting = false;
    });
    
    // Restart timer
    _timer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectAnswer(String questionId, String answerId) {
    final question = widget.quiz.questions.firstWhere((q) => q.id == questionId);
    
    setState(() {
      if (question.questionType == QuestionType.multipleChoice) {
        // Toggle answer for multiple choice
        if (_multipleSelectedAnswers[questionId] == null) {
          _multipleSelectedAnswers[questionId] = {};
        }
        if (_multipleSelectedAnswers[questionId]!.contains(answerId)) {
          _multipleSelectedAnswers[questionId]!.remove(answerId);
        } else {
          _multipleSelectedAnswers[questionId]!.add(answerId);
        }
      } else {
        // Single choice or true/false
        _selectedAnswers[questionId] = answerId;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitQuiz() async {
    if (_isSubmitted || _isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    _timer?.cancel();

    // Prepare answers payload for API
    List<Map<String, dynamic>> answersPayload = [];
    
    for (var question in widget.quiz.questions) {
      List<String> selectedAnswerIds = [];
      
      if (question.questionType == QuestionType.multipleChoice) {
        // Multiple choice
        final multipleAnswers = _multipleSelectedAnswers[question.id];
        if (multipleAnswers != null && multipleAnswers.isNotEmpty) {
          selectedAnswerIds = multipleAnswers.toList();
        }
      } else {
        // Single choice or true/false
        final singleAnswer = _selectedAnswers[question.id];
        if (singleAnswer != null) {
          selectedAnswerIds = [singleAnswer];
        }
      }
      
      if (selectedAnswerIds.isNotEmpty) {
        answersPayload.add({
          'questionId': question.id,
          'selectedAnswerIds': selectedAnswerIds,
          'textAnswer': '', // Empty for choice questions
        });
      }
    }

    print('📤 Submitting quiz with ${answersPayload.length} answers');

    // Call submit API
    final submitResult = await _quizService.submitQuiz(
      quizId: widget.quiz.id,
      answers: answersPayload,
    );

    if (!mounted) return;

    if (submitResult['success'] == true) {
      _isSubmitted = true;
      
      final responseData = submitResult['data'];
      
      // Extract API response data
      int score = responseData?['scorePercent'] ?? 0;
      bool isPassed = responseData?['passed'] ?? false;
      final questionResults = responseData?['questionResults'] as List?;
      
      print('✅ Quiz submitted - Score: $score%, Passed: $isPassed');
      
      // Build user answers list from API response
      List<UserAnswer> userAnswers = [];
      
      if (questionResults != null) {
        // Use API response data
        for (var questionResult in questionResults) {
          final questionId = questionResult['questionId'];
          final isCorrect = questionResult['isCorrect'] ?? false;
          final selectedAnswerIds = List<String>.from(questionResult['selectedAnswerIds'] ?? []);
          
          // Update quiz questions with correct answer info from API
          final questionIndex = widget.quiz.questions.indexWhere((q) => q.id == questionId);
          if (questionIndex != -1) {
            final answers = questionResult['answers'] as List?;
            if (answers != null) {
              // Find correct answer ID from API response
              for (var answer in answers) {
                if (answer['isCorrect'] == true) {
                  widget.quiz.questions[questionIndex] = QuizQuestion(
                    id: widget.quiz.questions[questionIndex].id,
                    question: widget.quiz.questions[questionIndex].question,
                    answers: widget.quiz.questions[questionIndex].answers,
                    correctAnswerId: answer['answerId'],
                    explanation: widget.quiz.questions[questionIndex].explanation,
                    questionType: widget.quiz.questions[questionIndex].questionType,
                  );
                  break;
                }
              }
            }
          }
          
          userAnswers.add(UserAnswer(
            questionId: questionId,
            selectedAnswerId: selectedAnswerIds.isNotEmpty ? selectedAnswerIds.first : null,
            selectedAnswerIds: selectedAnswerIds.length > 1 ? selectedAnswerIds : null,
            isCorrect: isCorrect,
          ));
        }
      } else {
        // Fallback if API doesn't return questionResults
        for (var question in widget.quiz.questions) {
          String? selectedAnswerId;
          List<String>? selectedAnswerIds;
          
          if (question.questionType == QuestionType.multipleChoice) {
            selectedAnswerIds = _multipleSelectedAnswers[question.id]?.toList();
          } else {
            selectedAnswerId = _selectedAnswers[question.id];
          }
          
          userAnswers.add(UserAnswer(
            questionId: question.id,
            selectedAnswerId: selectedAnswerId,
            selectedAnswerIds: selectedAnswerIds,
            isCorrect: false,
          ));
        }
      }

      int timeSpent = (widget.quiz.timeLimit * 60) - _remainingSeconds;

      QuizResult result = QuizResult(
        id: 'result-${DateTime.now().millisecondsSinceEpoch}',
        quizId: widget.quiz.id,
        userId: 'current-user',
        completedAt: DateTime.now(),
        score: score,
        userAnswers: userAnswers,
        timeSpent: timeSpent,
        isPassed: isPassed,
      );

      print('✅ Quiz submitted - Score: ${result.score}%, Passed: ${result.isPassed}');

      // Navigate to result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            quiz: widget.quiz,
            result: result,
            isReview: false,
          ),
        ),
      ).then((resultAction) {
        if (resultAction == 'restart_quiz') {
          _resetQuiz();
        } else {
          Navigator.pop(context, result);
        }
      });
    } else {
      // Show error
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(submitResult['message'] ?? 'Không thể nộp bài kiểm tra'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _showSubmitDialog() {
    if (_isSubmitting) return; // Prevent showing dialog while submitting
    
    // Count answered questions
    int answered = 0;
    for (var question in widget.quiz.questions) {
      if (question.questionType == QuestionType.multipleChoice) {
        if (_multipleSelectedAnswers[question.id]?.isNotEmpty ?? false) {
          answered++;
        }
      } else {
        if (_selectedAnswers[question.id] != null) {
          answered++;
        }
      }
    }
    int unanswered = widget.quiz.questions.length - answered;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nộp bài kiểm tra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có chắc chắn muốn nộp bài?'),
              const SizedBox(height: 8),
              if (unanswered > 0)
                Text(
                  'Còn $unanswered câu hỏi chưa trả lời.',
                  style: const TextStyle(
                    color: AppColors.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () {
                Navigator.pop(context);
                _submitQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Nộp bài'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('${_currentQuestionIndex + 1}/${widget.quiz.questions.length}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thoát bài kiểm tra'),
                  content: const Text('Bạn có chắc chắn muốn thoát? Kết quả sẽ không được lưu.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Ở lại'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Thoát',
                        style: TextStyle(color: AppColors.errorColor),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: _remainingSeconds < 300 // Less than 5 minutes
                  ? AppColors.errorColor.withOpacity(0.1)
                  : AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer,
                  size: 16,
                  color: _remainingSeconds < 300 
                      ? AppColors.errorColor 
                      : AppColors.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _remainingSeconds < 300 
                        ? AppColors.errorColor 
                        : AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              minHeight: 6,
            ),
          ),
          
          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionCard(currentQuestion),
                  const SizedBox(height: 24),
                  _buildAnswerOptions(currentQuestion),
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    // Determine icon and label based on question type
    IconData icon;
    String label;
    Color badgeColor;
    
    switch (question.questionType) {
      case QuestionType.singleChoice:
        icon = Icons.radio_button_checked;
        label = 'Chọn một đáp án';
        badgeColor = AppColors.primaryColor;
        break;
      case QuestionType.multipleChoice:
        icon = Icons.check_box;
        label = 'Chọn nhiều đáp án';
        badgeColor = AppColors.secondaryColor;
        break;
      case QuestionType.trueFalse:
        icon = Icons.check_circle;
        label = 'Đúng / Sai';
        badgeColor = AppColors.infoColor;
        break;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${_currentQuestionIndex + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Câu hỏi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(icon, size: 14, color: badgeColor),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: badgeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(QuizQuestion question) {
    if (question.questionType == QuestionType.trueFalse) {
      return _buildTrueFalseOptions(question);
    } else if (question.questionType == QuestionType.multipleChoice) {
      return _buildMultipleChoiceOptions(question);
    } else {
      return _buildSingleChoiceOptions(question);
    }
  }

  Widget _buildSingleChoiceOptions(QuizQuestion question) {
    return Column(
      children: question.answers.map((answer) {
        bool isSelected = _selectedAnswers[question.id] == answer.id;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _selectAnswer(question.id, answer.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.primaryColor 
                      : AppColors.borderColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? AppColors.primaryColor 
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.primaryColor 
                            : AppColors.borderColor,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      answer.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected 
                            ? AppColors.primaryColor 
                            : AppColors.textPrimaryColor,
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceOptions(QuizQuestion question) {
    final selectedIds = _multipleSelectedAnswers[question.id] ?? {};
    
    return Column(
      children: question.answers.map((answer) {
        bool isSelected = selectedIds.contains(answer.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _selectAnswer(question.id, answer.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.secondaryColor.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? AppColors.secondaryColor 
                      : AppColors.borderColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isSelected 
                          ? AppColors.secondaryColor 
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected 
                            ? AppColors.secondaryColor 
                            : AppColors.borderColor,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      answer.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected 
                            ? AppColors.secondaryColor 
                            : AppColors.textPrimaryColor,
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions(QuizQuestion question) {
    return Row(
      children: [
        // True option
        Expanded(
          child: _buildTrueFalseButton(
            question: question,
            isTrue: true,
          ),
        ),
        const SizedBox(width: 16),
        // False option
        Expanded(
          child: _buildTrueFalseButton(
            question: question,
            isTrue: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalseButton({
    required QuizQuestion question,
    required bool isTrue,
  }) {
    // Find the answer that represents true or false
    final answer = question.answers.firstWhere(
      (a) => a.text.toLowerCase() == (isTrue ? 'đúng' : 'sai') ||
             a.text.toLowerCase() == (isTrue ? 'true' : 'false'),
      orElse: () => question.answers[isTrue ? 0 : 1],
    );
    
    bool isSelected = _selectedAnswers[question.id] == answer.id;
    
    return InkWell(
      onTap: () => _selectAnswer(question.id, answer.id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isTrue ? AppColors.successColor : AppColors.errorColor).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? (isTrue ? AppColors.successColor : AppColors.errorColor)
                : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isTrue ? AppColors.successColor : AppColors.errorColor)
                    : AppColors.borderColor.withOpacity(0.3),
              ),
              child: Icon(
                isTrue ? Icons.check : Icons.close,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isTrue ? 'ĐÚNG' : 'SAI',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? (isTrue ? AppColors.successColor : AppColors.errorColor)
                    : AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    bool isLastQuestion = _currentQuestionIndex == widget.quiz.questions.length - 1;
    final currentQuestion = widget.quiz.questions[_currentQuestionIndex];
    
    bool hasAnsweredCurrent = false;
    if (currentQuestion.questionType == QuestionType.multipleChoice) {
      hasAnsweredCurrent = _multipleSelectedAnswers[currentQuestion.id]?.isNotEmpty ?? false;
    } else {
      hasAnsweredCurrent = _selectedAnswers.containsKey(currentQuestion.id);
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Câu trước',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            const Expanded(child: SizedBox()),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: ElevatedButton(
              onPressed: isLastQuestion 
                  ? _showSubmitDialog
                  : hasAnsweredCurrent 
                      ? _nextQuestion 
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLastQuestion ? 'Nộp bài' : 'Câu tiếp theo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}