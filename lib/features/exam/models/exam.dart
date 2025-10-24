class Exam {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String courseName;
  final String subject;
  final DateTime? startDate;
  final DateTime? endDate;
  final int duration; // in minutes
  final int totalQuestions;
  final double passingScore;
  final bool isEnrolled;
  final bool isCompleted;
  final double? lastScore;
  final DateTime? lastAttemptDate;
  final int maxAttempts;
  final int currentAttempts;
  final ExamDifficulty difficulty;
  final List<String> topics;
  final String? instructions;

  const Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseName,
    required this.subject,
    this.startDate,
    this.endDate,
    required this.duration,
    required this.totalQuestions,
    required this.passingScore,
    required this.isEnrolled,
    this.isCompleted = false,
    this.lastScore,
    this.lastAttemptDate,
    this.maxAttempts = 3,
    this.currentAttempts = 0,
    required this.difficulty,
    required this.topics,
    this.instructions,
  });

  bool get isAvailable {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  bool get canTakeExam {
    return isEnrolled && isAvailable && currentAttempts < maxAttempts;
  }

  String get statusText {
    if (!isEnrolled) return 'Chưa đăng ký';
    if (!isAvailable) {
      if (startDate != null && DateTime.now().isBefore(startDate!)) {
        return 'Chưa mở';
      }
      if (endDate != null && DateTime.now().isAfter(endDate!)) {
        return 'Đã kết thúc';
      }
    }
    if (isCompleted) return 'Đã hoàn thành';
    if (currentAttempts >= maxAttempts) return 'Hết lượt thi';
    return 'Có thể thi';
  }

  ExamStatus get status {
    if (!isEnrolled) return ExamStatus.notEnrolled;
    if (!isAvailable) return ExamStatus.unavailable;
    if (isCompleted) return ExamStatus.completed;
    if (currentAttempts >= maxAttempts) return ExamStatus.outOfAttempts;
    return ExamStatus.available;
  }
}

enum ExamDifficulty {
  easy,
  medium,
  hard,
}

enum ExamStatus {
  notEnrolled,
  available,
  unavailable,
  completed,
  outOfAttempts,
}

extension ExamDifficultyExtension on ExamDifficulty {
  String get displayName {
    switch (this) {
      case ExamDifficulty.easy:
        return 'Dễ';
      case ExamDifficulty.medium:
        return 'Trung bình';
      case ExamDifficulty.hard:
        return 'Khó';
    }
  }
}

class ExamResult {
  final String id;
  final String examId;
  final String userId;
  final double score;
  final bool isPassed;
  final DateTime completedAt;
  final int timeSpent; // in seconds
  final Map<String, dynamic> answers;

  const ExamResult({
    required this.id,
    required this.examId,
    required this.userId,
    required this.score,
    required this.isPassed,
    required this.completedAt,
    required this.timeSpent,
    required this.answers,
  });
}