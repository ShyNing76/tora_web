import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../features/course/models/quiz.dart';

class QuizResultScreen extends StatelessWidget {
  final Quiz quiz;
  final QuizResult result;
  final bool isReview;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.result,
    this.isReview = false,
  });

  @override
  Widget build(BuildContext context) {
    int correctAnswers = result.userAnswers.where((ua) => ua.isCorrect).length;
    
    return WillPopScope(
      onWillPop: () async {
        // Handle back gesture/button safely
        Navigator.pop(context);
        return false; // Prevent default back action
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(isReview ? 'Xem lại kết quả' : 'Kết quả bài kiểm tra'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildResultHeader(correctAnswers),
            const SizedBox(height: 24),
            _buildResultStats(correctAnswers),
            const SizedBox(height: 24),
            _buildReviewSection(),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildResultHeader(int correctAnswers) {
    bool isPassed = result.isPassed;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPassed
              ? [AppColors.successColor, AppColors.successColor.withOpacity(0.8)]
              : [AppColors.errorColor, AppColors.errorColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: 
            // Icon(
            //   isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            //   size: 40,
            //   color: Colors.white,
            // ),
            Image.asset(isPassed ? 'assets/images/mascot/tora_cool.png': 'assets/images/mascot/tora_cry.png',
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            isPassed ? 'Chúc mừng!' : 'Chưa đạt yêu cầu',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            isPassed 
                ? 'Chúc mừng bạn đã vượt qua bài kiểm tra, hãy tiếp tục phát huy!'
                : 'Rất tiếc! Bạn chưa đạt yêu cầu để vượt qua bài kiểm tra. Hãy ôn tập thêm và thử lại!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '${result.score}%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isPassed ? AppColors.successColor : AppColors.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStats(int correctAnswers) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết kết quả',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildStatItem(
                icon: Icons.quiz,
                label: 'Tổng câu hỏi',
                value: '${quiz.questions.length}',
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                icon: Icons.check_circle,
                label: 'Trả lời đúng',
                value: '$correctAnswers',
                color: AppColors.successColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildStatItem(
                icon: Icons.cancel,
                label: 'Trả lời sai',
                value: '${quiz.questions.length - correctAnswers}',
                color: AppColors.errorColor,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                icon: Icons.timer,
                label: 'Thời gian',
                value: _formatTime(result.timeSpent),
                color: AppColors.primaryColor,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.isPassed 
                  ? AppColors.successColor.withOpacity(0.1)
                  : AppColors.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  result.isPassed ? Icons.thumb_up : Icons.thumb_down,
                  color: result.isPassed 
                      ? AppColors.successColor 
                      : AppColors.errorColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    result.isPassed 
                        ? 'Bạn đã đạt điểm tối thiểu ${quiz.passingScore}% để vượt qua bài kiểm tra'
                        : 'Bạn cần đạt tối thiểu ${quiz.passingScore}% để vượt qua bài kiểm tra',
                    style: TextStyle(
                      fontSize: 14,
                      color: result.isPassed 
                          ? AppColors.successColor 
                          : AppColors.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xem lại đáp án',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          ...quiz.questions.asMap().entries.map((entry) {
            int index = entry.key;
            QuizQuestion question = entry.value;
            UserAnswer? userAnswer = result.userAnswers.firstWhere(
              (ua) => ua.questionId == question.id,
              orElse: () => UserAnswer(
                questionId: question.id,
                selectedAnswerId: null,
                isCorrect: false,
              ),
            );
            
            return _buildQuestionReview(question, userAnswer, index + 1);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuestionReview(QuizQuestion question, UserAnswer userAnswer, int questionNumber) {
    // Get selected answer(s)
    List<QuizAnswer> selectedAnswers = [];
    if (question.questionType == QuestionType.multipleChoice && userAnswer.selectedAnswerIds != null) {
      // Multiple choice
      for (var answerId in userAnswer.selectedAnswerIds!) {
        try {
          selectedAnswers.add(
            question.answers.firstWhere((a) => a.id == answerId),
          );
        } catch (e) {
          // Answer not found, skip
        }
      }
    } else if (userAnswer.selectedAnswerId != null) {
      // Single choice or true/false
      try {
        selectedAnswers.add(
          question.answers.firstWhere((a) => a.id == userAnswer.selectedAnswerId),
        );
      } catch (e) {
        // Answer not found, skip
      }
    }
    
    // Get correct answer if available
    QuizAnswer? correctAnswer;
    try {
      if (question.correctAnswerId.isNotEmpty) {
        correctAnswer = question.answers.firstWhere(
          (a) => a.id == question.correctAnswerId,
        );
      }
    } catch (e) {
      // Correct answer not found
      correctAnswer = null;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: userAnswer.isCorrect 
              ? AppColors.successColor.withOpacity(0.3)
              : AppColors.errorColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: userAnswer.isCorrect 
                      ? AppColors.successColor 
                      : AppColors.errorColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  userAnswer.isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Câu $questionNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          if (selectedAnswers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: userAnswer.isCorrect 
                    ? AppColors.successColor.withOpacity(0.1)
                    : AppColors.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    userAnswer.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: userAnswer.isCorrect 
                        ? AppColors.successColor 
                        : AppColors.errorColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedAnswers.length > 1 ? 'Bạn chọn:' : 'Bạn chọn: ${selectedAnswers.first.text}',
                          style: TextStyle(
                            fontSize: 14,
                            color: userAnswer.isCorrect 
                                ? AppColors.successColor 
                                : AppColors.errorColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (selectedAnswers.length > 1) ...[
                          const SizedBox(height: 4),
                          ...selectedAnswers.map((answer) => Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '• ${answer.text}',
                              style: TextStyle(
                                fontSize: 14,
                                color: userAnswer.isCorrect 
                                    ? AppColors.successColor 
                                    : AppColors.errorColor,
                              ),
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: AppColors.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Không trả lời',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          if (!userAnswer.isCorrect && correctAnswer != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đáp án đúng: ${correctAnswer.text}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (question.explanation != null && question.explanation!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.infoColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              try {
                Navigator.of(context).pop();
              } catch (e) {
                print('Navigation error: $e');
                // If pop fails, try to go to previous route
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isReview ? 'Đóng' : 'Quay lại quiz',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        if (!isReview) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                try {
                  Navigator.of(context).pop('restart_quiz');
                } catch (e) {
                  print('Navigation error: $e');
                  Navigator.of(context).pop();
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Làm lại bài kiểm tra',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes} phút ${remainingSeconds} giây';
  }
}