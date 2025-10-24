import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/chapter.dart';
import '../models/quiz.dart';
import '../services/quiz_service.dart';
import '../services/lesson_service.dart';
import '../views/quiz_taking_screen.dart';
import '../views/quiz_result_screen.dart';

class LessonQuizTab extends StatefulWidget {
  final Lesson lesson;
  final String courseId;

  const LessonQuizTab({
    super.key,
    required this.lesson,
    required this.courseId,
  });

  @override
  State<LessonQuizTab> createState() => _LessonQuizTabState();
}

class _LessonQuizTabState extends State<LessonQuizTab> {
  final QuizService _quizService = QuizService();
  final LessonService _lessonService = LessonService();

  Quiz? _quiz;
  List<QuizResult> _quizHistory = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Load quiz from API
    final result = await _quizService.getQuizByLessonId(widget.lesson.id);

    if (result['success'] == true && mounted) {
      setState(() {
        _quiz = result['quiz'] as Quiz;
        _quizHistory = _createMockHistory(); // TODO: Load from API later
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Không thể tải bài kiểm tra';
      });
    }
  }

  List<QuizResult> _createMockHistory() {
    return [
      QuizResult(
        id: 'result-1',
        quizId: 'quiz-lesson-${widget.lesson.id}',
        userId: 'user-1',
        score: 85,
        userAnswers: [
          UserAnswer(questionId: 'q1', selectedAnswerId: 'a1', isCorrect: true),
          UserAnswer(questionId: 'q2', selectedAnswerId: 'b2', isCorrect: true),
          UserAnswer(questionId: 'q3', selectedAnswerId: 'c1', isCorrect: true),
        ],
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        timeSpent: 480, // 8 minutes in seconds
        isPassed: true,
      ),
      QuizResult(
        id: 'result-2',
        quizId: 'quiz-lesson-${widget.lesson.id}',
        userId: 'user-1',
        score: 65,
        userAnswers: [
          UserAnswer(questionId: 'q1', selectedAnswerId: 'a1', isCorrect: true),
          UserAnswer(
            questionId: 'q2',
            selectedAnswerId: 'b1',
            isCorrect: false,
          ),
          UserAnswer(questionId: 'q3', selectedAnswerId: 'c1', isCorrect: true),
        ],
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
        timeSpent: 600, // 10 minutes in seconds
        isPassed: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_quiz == null) {
      return _buildNoQuizView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuizHeader(),
          const SizedBox(height: 24),
          _buildQuizInfo(),
          const SizedBox(height: 24),
          _buildStartButton(),
          const SizedBox(height: 32),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadQuizData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoQuizView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: AppColors.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có bài kiểm tra',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bài học này chưa có bài kiểm tra.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
                // const Icon(
                //   Icons.assignment_outlined,
                //   size: 40,
                //   color: Colors.white,
                // ),
                Image.asset(
                  'assets/images/mascot/tora_quiz.png',
                  width: 40,
                  height: 40,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            _quiz!.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _quiz!.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfo() {
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
            'Thông tin bài kiểm tra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            _quiz!.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryColor,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _buildInfoItem(
                icon: Icons.quiz_outlined,
                label: 'Số câu hỏi',
                value: '${_quiz!.questions.length}',
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                icon: Icons.timer_outlined,
                label: 'Thời gian',
                value: '${_quiz!.timeLimit} phút',
                color: AppColors.warningColor,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _buildInfoItem(
                icon: Icons.grade_outlined,
                label: 'Điểm đạt',
                value: '${_quiz!.passingScore}%',
                color: AppColors.successColor,
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                icon: Icons.workspace_premium_outlined,
                label: 'Độ khó',
                value: 'Cơ bản',
                color: AppColors.infoColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
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
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final hasAttempts = _quizHistory.isNotEmpty;
    final lastResult = hasAttempts ? _quizHistory.first : null;
    final hasPassed = lastResult?.isPassed ?? false;

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Navigate to quiz taking screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizTakingScreen(
                quiz: _quiz!,
                lesson: widget.lesson,
              ),
            ),
          );

          // Reload quiz data after returning
          if (result != null && mounted) {
            _loadQuizData();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: hasPassed
              ? AppColors.successColor
              : AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(hasPassed ? Icons.refresh : Icons.play_arrow, size: 20),
            const SizedBox(width: 8),
            Text(
              hasPassed ? 'Làm lại bài kiểm tra' : 'Bắt đầu kiểm tra',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_quizHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: AppColors.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch sử làm bài',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy bắt đầu bài kiểm tra đầu tiên của bạn!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lịch sử làm bài',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(_quizHistory.length, (index) {
          final result = _quizHistory[index];
          return _buildHistoryItem(result, index);
        }),
      ],
    );
  }

  Widget _buildHistoryItem(QuizResult result, int index) {
    final isPassed = result.isPassed;
    final statusColor = isPassed
        ? AppColors.successColor
        : AppColors.errorColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  QuizResultScreen(result: result, quiz: _quiz!),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPassed ? Icons.check_circle : Icons.cancel,
                color: statusColor,
                size: 20,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lần ${_quizHistory.length - index}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      Text(
                        '${result.score}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(result.timeSpent / 60).round()} phút',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.quiz_outlined,
                        size: 12,
                        color: AppColors.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${result.userAnswers.where((ua) => ua.isCorrect).length}/${result.userAnswers.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _formatDate(result.completedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
