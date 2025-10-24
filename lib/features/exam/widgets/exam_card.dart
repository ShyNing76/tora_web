import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exam.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback? onTap;

  const ExamCard({
    super.key,
    required this.exam,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 100,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildCourseInfo(),
                const SizedBox(height: 12),
                _buildExamDetails(),
                const SizedBox(height: 16),
                _buildActionSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getSubjectColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            exam.subject,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getSubjectColor(),
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            exam.statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      exam.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimaryColor,
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Row(
      children: [
        Icon(
          Icons.book_outlined,
          size: 14,
          color: AppColors.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            exam.courseName,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildExamDetails() {
    return Row(
      children: [
        _buildDetailItem(
          icon: Icons.schedule_rounded,
          text: '${exam.duration} phút',
        ),
        const SizedBox(width: 16),
        _buildDetailItem(
          icon: Icons.quiz_rounded,
          text: '${exam.totalQuestions} câu',
        ),
        const SizedBox(width: 16),
        _buildDetailItem(
          icon: Icons.grade_outlined,
          text: '${exam.passingScore.toInt()}%',
        ),
        const SizedBox(width: 16),
        _buildDetailItem(
          icon: Icons.signal_cellular_alt,
          text: exam.difficulty.displayName,
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    if (exam.isCompleted) {
      return _buildCompletedSection();
    }

    if (!exam.isEnrolled) {
      return _buildEnrollSection();
    }

    if (!exam.canTakeExam) {
      return _buildUnavailableSection();
    }

    return _buildAvailableSection();
  }

  Widget _buildCompletedSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.successColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đã hoàn thành',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successColor,
                  ),
                ),
                if (exam.lastScore != null)
                  Text(
                    'Điểm: ${exam.lastScore!.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.successColor.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: null, // Will be handled by parent onTap
            child: const Text('Xem kết quả'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.warningColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cần đăng ký khóa học để tham gia bài thi',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.warningColor,
              ),
            ),
          ),
          TextButton(
            onPressed: null, // Will be handled by parent onTap
            child: const Text('Đăng ký'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableSection() {
    String message = '';
    IconData icon = Icons.schedule;
    
    if (exam.currentAttempts >= exam.maxAttempts) {
      message = 'Đã hết lượt thi (${exam.currentAttempts}/${exam.maxAttempts})';
      icon = Icons.block;
    } else if (!exam.isAvailable) {
      if (exam.startDate != null && DateTime.now().isBefore(exam.startDate!)) {
        message = 'Bài thi chưa mở';
      } else if (exam.endDate != null && DateTime.now().isAfter(exam.endDate!)) {
        message = 'Bài thi đã kết thúc';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.textSecondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_circle_outline,
            color: AppColors.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sẵn sàng làm bài',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  'Lượt thi: ${exam.currentAttempts}/${exam.maxAttempts}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: null, // Will be handled by parent onTap
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Bắt đầu',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (exam.status) {
      case ExamStatus.notEnrolled:
        return AppColors.warningColor;
      case ExamStatus.available:
        return AppColors.primaryColor;
      case ExamStatus.unavailable:
        return AppColors.textSecondaryColor;
      case ExamStatus.completed:
        return AppColors.successColor;
      case ExamStatus.outOfAttempts:
        return AppColors.errorColor;
    }
  }

  Color _getSubjectColor() {
    switch (exam.subject.toLowerCase()) {
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