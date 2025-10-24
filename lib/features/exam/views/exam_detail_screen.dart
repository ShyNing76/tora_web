import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exam.dart';
import '../../course/models/quiz.dart';
import '../../course/models/chapter.dart';
import '../../course/views/quiz_taking_screen.dart';
import '../../course/views/quiz_result_screen.dart';

class ExamDetailScreen extends StatefulWidget {
  final Exam exam;

  const ExamDetailScreen({
    super.key,
    required this.exam,
  });

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  Quiz? _quiz;
  List<QuizResult> _examHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExamData();
  }

  void _loadExamData() {
    // Convert Exam to Quiz for compatibility with existing quiz system
    _quiz = _convertExamToQuiz(widget.exam);
    _examHistory = _createMockHistory();
    
    setState(() {
      _isLoading = false;
    });
  }

  Quiz _convertExamToQuiz(Exam exam) {
    // Create quiz questions based on exam topics
    List<QuizQuestion> questions = [];
    
    for (int i = 0; i < exam.totalQuestions; i++) {
      final topic = exam.topics[i % exam.topics.length];
      questions.add(
        QuizQuestion(
          id: 'q${i + 1}',
          question: 'Câu hỏi ${i + 1} về $topic',
          correctAnswerId: 'a1',
          explanation: 'Giải thích cho câu hỏi về $topic.',
          answers: [
            QuizAnswer(id: 'a1', text: 'Đáp án A'),
            QuizAnswer(id: 'a2', text: 'Đáp án B'),
            QuizAnswer(id: 'a3', text: 'Đáp án C'),
            QuizAnswer(id: 'a4', text: 'Đáp án D'),
          ],
        ),
      );
    }

    return Quiz(
      id: exam.id,
      title: exam.title,
      description: exam.description,
      timeLimit: exam.duration,
      passingScore: exam.passingScore.toInt(),
      questions: questions,
    );
  }

  List<QuizResult> _createMockHistory() {
    if (!widget.exam.isEnrolled || widget.exam.currentAttempts == 0) {
      return [];
    }

    List<QuizResult> history = [];
    
    // Add mock results based on current attempts
    for (int i = 0; i < widget.exam.currentAttempts; i++) {
      final isLastAttempt = i == widget.exam.currentAttempts - 1;
      final score = isLastAttempt && widget.exam.lastScore != null 
          ? widget.exam.lastScore! 
          : 60.0 + (i * 5.0); // Progressive improvement
      
      history.add(
        QuizResult(
          id: 'result-${i + 1}',
          quizId: widget.exam.id,
          userId: 'user-1',
          score: score.toInt(),
          userAnswers: [], // Mock answers
          completedAt: isLastAttempt && widget.exam.lastAttemptDate != null
              ? widget.exam.lastAttemptDate!
              : DateTime.now().subtract(Duration(days: i + 1)),
          timeSpent: widget.exam.duration * 60 - (i * 60), // Varied time
          isPassed: score >= widget.exam.passingScore,
        ),
      );
    }

    return history.reversed.toList(); // Most recent first
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: const Text('Chi tiết bài thi'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(widget.exam.title),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExamHeader(),
            const SizedBox(height: 24),
            _buildExamInfo(),
            const SizedBox(height: 24),
            _buildRequirements(),
            const SizedBox(height: 24),
            _buildActionButton(),
            const SizedBox(height: 32),
            if (_examHistory.isNotEmpty) _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExamHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSubjectColor(),
            _getSubjectColor().withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.exam.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.exam.subject,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.exam.courseName,
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

  Widget _buildExamInfo() {
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
            'Thông tin bài thi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            widget.exam.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryColor,
              height: 1.5,
            ),
          ),
          
          if (widget.exam.instructions != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.exam.instructions!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Exam details grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.quiz_outlined,
                  label: 'Số câu hỏi',
                  value: '${widget.exam.totalQuestions}',
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.timer_outlined,
                  label: 'Thời gian',
                  value: '${widget.exam.duration} phút',
                  color: AppColors.warningColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.grade_outlined,
                  label: 'Điểm đạt',
                  value: '${widget.exam.passingScore.toInt()}%',
                  color: AppColors.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.repeat,
                  label: 'Số lần thi',
                  value: '${widget.exam.currentAttempts}/${widget.exam.maxAttempts}',
                  color: AppColors.infoColor,
                ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
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
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirements() {
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
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.infoColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Yêu cầu và lưu ý',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ..._getRequirementsList().map((requirement) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    requirement,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryColor,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  List<String> _getRequirementsList() {
    List<String> requirements = [
      'Bạn cần đăng ký khóa học để tham gia bài thi',
      'Thời gian làm bài là ${widget.exam.duration} phút, không thể tạm dừng',
      'Mỗi câu hỏi chỉ có thể chọn một đáp án',
      'Cần đạt ít nhất ${widget.exam.passingScore.toInt()}% để vượt qua bài thi',
      'Bạn có tối đa ${widget.exam.maxAttempts} lần làm bài thi này',
    ];

    if (widget.exam.startDate != null) {
      requirements.add('Bài thi mở từ ${_formatDateTime(widget.exam.startDate!)}');
    }
    
    if (widget.exam.endDate != null) {
      requirements.add('Bài thi đóng vào ${_formatDateTime(widget.exam.endDate!)}');
    }

    return requirements;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildActionButton() {
    if (!widget.exam.isEnrolled) {
      return _buildEnrollButton();
    }

    if (!widget.exam.canTakeExam) {
      return _buildUnavailableButton();
    }

    return _buildStartExamButton();
  }

  Widget _buildEnrollButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement course enrollment
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tính năng đăng ký khóa học sẽ sớm được cập nhật')),
          );
        },
        icon: const Icon(Icons.school_outlined),
        label: const Text('Đăng ký khóa học'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warningColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildUnavailableButton() {
    String message = widget.exam.statusText;
    
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textSecondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(message),
      ),
    );
  }

  Widget _buildStartExamButton() {
    final isRetake = widget.exam.currentAttempts > 0;
    
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _startExam();
        },
        icon: Icon(isRetake ? Icons.refresh : Icons.play_arrow),
        label: Text(isRetake ? 'Làm lại bài thi' : 'Bắt đầu bài thi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isRetake ? AppColors.infoColor : AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _startExam() {
    if (_quiz == null) return;

    // Create a mock lesson for compatibility
    // final mockLesson = Lesson(
    //   id: 'lesson-exam-${widget.exam.id}',
    //   title: widget.exam.title,
    //   description: widget.exam.description,
    //   content: '',
    //   videoUrl: null,
    //   durationMinutes: widget.exam.duration,
    //   type: LessonType.quiz,
    //   order: 1,
    //   isLocked: false,
    //   isCompleted: widget.exam.isCompleted,
    // );

    final mockLesson = QuizLesson(
      id: 'lesson-exam-${widget.exam.id}',
      name: widget.exam.title,
      description: widget.exam.description,
      timeInMinutes: widget.exam.duration,
      isCompleted: widget.exam.isCompleted,
      ordering: 1,
      chapterId: 'chapter-exam-${widget.exam.id}',
      flashcards: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizTakingScreen(
          quiz: _quiz!,
          lesson: mockLesson,
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
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
        ...List.generate(_examHistory.length, (index) {
          final result = _examHistory[index];
          return _buildHistoryItem(result, index);
        }),
      ],
    );
  }

  Widget _buildHistoryItem(QuizResult result, int index) {
    final isPassed = result.isPassed;
    final statusColor = isPassed ? AppColors.successColor : AppColors.errorColor;
    
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
          if (_quiz != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizResultScreen(
                  result: result,
                  quiz: _quiz!,
                ),
              ),
            );
          }
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
                        'Lần ${_examHistory.length - index}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryColor,
                        ),
                      ),
                      Text(
                        '${result.score.toStringAsFixed(1)}%',
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

  Color _getSubjectColor() {
    switch (widget.exam.subject.toLowerCase()) {
      case 'toán học':
        return AppColors.mathColor;
      case 'vật lý':
        return AppColors.physicsColor;
      case 'hóa học':
        return AppColors.chemistryColor;
      case 'văn học':
      case 'ngữ văn':
        return AppColors.literatureColor;
      case 'kỹ năng mềm':
        return AppColors.infoColor;
      default:
        return AppColors.primaryColor;
    }
  }
}