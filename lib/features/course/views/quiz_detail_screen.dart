import 'package:flutter/material.dart';
import 'package:tora/features/course/models/chapter.dart';
import '../../../../core/constants/app_colors.dart';
// import '../../../../models/chapter.dart';
import '../../../features/course/models/quiz.dart';
import 'quiz_taking_screen.dart';
import 'quiz_result_screen.dart';

class QuizDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const QuizDetailScreen({
    super.key,
    required this.lesson,
  });

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  Quiz? _quiz;
  List<QuizResult> _quizHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  void _loadQuizData() {
    // Mock data - in real app, this would come from API
    _quiz = _createMockQuiz();
    _quizHistory = _createMockHistory();
    
    setState(() {
      _isLoading = false;
    });
  }

  Quiz _createMockQuiz() {
    return Quiz(
      id: 'quiz-1',
      title: widget.lesson.title,
      description: 'Kiểm tra kiến thức về ${widget.lesson.title}. Bạn cần đạt ít nhất 70% để vượt qua bài kiểm tra này.',
      timeLimit: 15, // 15 minutes
      passingScore: 70,
      questions: [
        QuizQuestion(
          id: 'q1',
          question: 'Khái niệm cơ bản nhất trong bài học này là gì?',
          correctAnswerId: 'a1',
          explanation: 'Đây là khái niệm nền tảng mà tất cả các kiến thức khác đều dựa vào để phát triển.',
          answers: [
            QuizAnswer(id: 'a1', text: 'Định nghĩa cốt lõi của chủ đề'),
            QuizAnswer(id: 'a2', text: 'Ví dụ minh họa'),
            QuizAnswer(id: 'a3', text: 'Bài tập thực hành'),
            QuizAnswer(id: 'a4', text: 'Tài liệu tham khảo'),
          ],
        ),
        QuizQuestion(
          id: 'q2',
          question: 'Tại sao việc hiểu rõ các nguyên lý cơ bản lại quan trọng?',
          correctAnswerId: 'b2',
          explanation: 'Nguyên lý cơ bản tạo nền tảng vững chắc cho việc học các chủ đề phức tạp hơn.',
          answers: [
            QuizAnswer(id: 'b1', text: 'Để làm bài thi tốt hơn'),
            QuizAnswer(id: 'b2', text: 'Để tạo nền tảng cho kiến thức nâng cao'),
            QuizAnswer(id: 'b3', text: 'Để ghi nhớ dễ dàng hơn'),
            QuizAnswer(id: 'b4', text: 'Để hoàn thành chương trình học'),
          ],
        ),
        QuizQuestion(
          id: 'q3',
          question: 'Cách tốt nhất để áp dụng kiến thức vào thực tế là gì?',
          correctAnswerId: 'c3',
          explanation: 'Phân tích tình huống thực tế giúp bạn hiểu cách áp dụng lý thuyết một cách hiệu quả.',
          answers: [
            QuizAnswer(id: 'c1', text: 'Học thuộc lòng tất cả định nghĩa'),
            QuizAnswer(id: 'c2', text: 'Làm nhiều bài tập lý thuyết'),
            QuizAnswer(id: 'c3', text: 'Phân tích và áp dụng vào tình huống thực tế'),
            QuizAnswer(id: 'c4', text: 'Đọc thêm nhiều sách tham khảo'),
          ],
        ),
        QuizQuestion(
          id: 'q4',
          question: 'Khi nào nên chuyển sang học chương tiếp theo?',
          correctAnswerId: 'd1',
          explanation: 'Việc nắm vững 100% kiến thức hiện tại là điều kiện cần thiết để học hiệu quả các chương sau.',
          answers: [
            QuizAnswer(id: 'd1', text: 'Khi đã nắm vững 100% kiến thức chương hiện tại'),
            QuizAnswer(id: 'd2', text: 'Khi cảm thấy chán với chương hiện tại'),
            QuizAnswer(id: 'd3', text: 'Khi có đủ thời gian học'),
            QuizAnswer(id: 'd4', text: 'Khi giáo viên yêu cầu'),
          ],
        ),
        QuizQuestion(
          id: 'q5',
          question: 'Phương pháp học tập hiệu quả nhất cho bài học này là gì?',
          correctAnswerId: 'e2',
          explanation: 'Kết hợp lý thuyết và thực hành giúp bạn hiểu sâu và nhớ lâu kiến thức.',
          answers: [
            QuizAnswer(id: 'e1', text: 'Chỉ đọc lý thuyết'),
            QuizAnswer(id: 'e2', text: 'Kết hợp lý thuyết và thực hành'),
            QuizAnswer(id: 'e3', text: 'Chỉ làm bài tập'),
            QuizAnswer(id: 'e4', text: 'Học nhóm với bạn bè'),
          ],
        ),
      ],
    );
  }

  List<QuizResult> _createMockHistory() {
    return [
      QuizResult(
        id: 'result-1',
        quizId: 'quiz-1',
        userId: 'user-1',
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        score: 80,
        timeSpent: 420, // 7 minutes
        isPassed: true,
        userAnswers: [],
      ),
      QuizResult(
        id: 'result-2',
        quizId: 'quiz-1',
        userId: 'user-1',
        completedAt: DateTime.now().subtract(const Duration(days: 7)),
        score: 60,
        timeSpent: 540, // 9 minutes
        isPassed: false,
        userAnswers: [],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _quiz == null) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom header with back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.lesson.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Image.asset('assets/images/mascot/tora_quiz.png',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 8),
          Text(
            _quiz!.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Bài kiểm tra này giúp bạn củng cố và đánh giá kiến thức đã học trong chương học.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
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
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                icon: Icons.timer_outlined,
                label: 'Thời gian',
                value: '${_quiz!.timeLimit} phút',
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
              ),
              const SizedBox(width: 24),
              _buildInfoItem(
                icon: Icons.repeat_outlined,
                label: 'Làm lại',
                value: 'Không giới hạn',
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
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizTakingScreen(
                quiz: _quiz!,
                lesson: widget.lesson,
              ),
            ),
          ).then((result) {
            if (result != null && result is QuizResult) {
              setState(() {
                _quizHistory.insert(0, result);
              });
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Bắt đầu làm bài',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_quizHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: AppColors.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có lịch sử làm bài',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy bắt đầu làm bài kiểm tra đầu tiên của bạn!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

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
            'Lịch sử làm bài',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._quizHistory.map((result) => _buildHistoryItem(result)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(QuizResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isPassed 
              ? AppColors.successColor.withOpacity(0.3)
              : AppColors.errorColor.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizResultScreen(
                quiz: _quiz!,
                result: result,
                isReview: true,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: result.isPassed 
                    ? AppColors.successColor.withOpacity(0.1)
                    : AppColors.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                result.isPassed ? Icons.check_circle : Icons.cancel,
                color: result.isPassed 
                    ? AppColors.successColor 
                    : AppColors.errorColor,
                size: 24,
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
                        '${result.score}% - ${result.isPassed ? 'Đạt' : 'Không đạt'}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: result.isPassed 
                              ? AppColors.successColor 
                              : AppColors.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(result.timeSpent / 60).floor()}m ${result.timeSpent % 60}s',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(result.completedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
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