import 'package:flutter/material.dart';

class UserProgress {
  final String userId;
  final int totalCoursesEnrolled;
  final int coursesCompleted;
  final int totalLessonsCompleted;
  final int totalQuizzesTaken;
  final int totalExamsTaken;
  final double averageQuizScore;
  final double averageExamScore;
  final int totalStudyTimeMinutes;
  final int currentStreak;
  final int longestStreak;
  final List<WeeklyProgress> weeklyProgress;
  final List<SubjectProgress> subjectProgress;
  final List<RecentActivity> recentActivities;

  const UserProgress({
    required this.userId,
    required this.totalCoursesEnrolled,
    required this.coursesCompleted,
    required this.totalLessonsCompleted,
    required this.totalQuizzesTaken,
    required this.totalExamsTaken,
    required this.averageQuizScore,
    required this.averageExamScore,
    required this.totalStudyTimeMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyProgress,
    required this.subjectProgress,
    required this.recentActivities,
  });

  double get courseCompletionRate {
    if (totalCoursesEnrolled == 0) return 0.0;
    return coursesCompleted / totalCoursesEnrolled;
  }

  String get totalStudyTime {
    final hours = totalStudyTimeMinutes ~/ 60;
    final minutes = totalStudyTimeMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class WeeklyProgress {
  final DateTime weekStart;
  final int lessonsCompleted;
  final int quizzesTaken;
  final int studyTimeMinutes;
  final double averageScore;

  const WeeklyProgress({
    required this.weekStart,
    required this.lessonsCompleted,
    required this.quizzesTaken,
    required this.studyTimeMinutes,
    required this.averageScore,
  });
}

class SubjectProgress {
  final String subject;
  final int totalLessons;
  final int completedLessons;
  final int totalQuizzes;
  final int completedQuizzes;
  final double averageScore;
  final String color; // Hex color for charts

  const SubjectProgress({
    required this.subject,
    required this.totalLessons,
    required this.completedLessons,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.averageScore,
    required this.color,
  });

  double get completionRate {
    final total = totalLessons + totalQuizzes;
    if (total == 0) return 0.0;
    final completed = completedLessons + completedQuizzes;
    return completed / total;
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final DateTime earnedAt;
  final AchievementType type;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.earnedAt,
    required this.type,
    required this.isUnlocked,
  });
}

enum AchievementType {
  course,
  quiz,
  streak,
  time,
  score,
}

class RecentActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;
  final String? relatedId; // Course ID, Quiz ID, etc.
  final Map<String, dynamic>? metadata;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.relatedId,
    this.metadata,
  });
}

enum ActivityType {
  lessonCompleted,
  quizCompleted,
  examCompleted,
  courseEnrolled,
  courseCompleted,
  achievementEarned,
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.lessonCompleted:
        return 'Hoàn thành bài học';
      case ActivityType.quizCompleted:
        return 'Hoàn thành bài kiểm tra';
      case ActivityType.examCompleted:
        return 'Hoàn thành bài thi';
      case ActivityType.courseEnrolled:
        return 'Đăng ký khóa học';
      case ActivityType.courseCompleted:
        return 'Hoàn thành khóa học';
      case ActivityType.achievementEarned:
        return 'Đạt thành tựu';
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityType.lessonCompleted:
        return Icons.play_lesson;
      case ActivityType.quizCompleted:
        return Icons.quiz;
      case ActivityType.examCompleted:
        return Icons.assignment_turned_in;
      case ActivityType.courseEnrolled:
        return Icons.school;
      case ActivityType.courseCompleted:
        return Icons.workspace_premium;
      case ActivityType.achievementEarned:
        return Icons.emoji_events;
    }
  }

  Color get color {
    switch (this) {
      case ActivityType.lessonCompleted:
        return const Color(0xFF4CAF50); // Green
      case ActivityType.quizCompleted:
        return const Color(0xFF2196F3); // Blue
      case ActivityType.examCompleted:
        return const Color(0xFF9C27B0); // Purple
      case ActivityType.courseEnrolled:
        return const Color(0xFFFF9800); // Orange
      case ActivityType.courseCompleted:
        return const Color(0xFF4CAF50); // Green
      case ActivityType.achievementEarned:
        return const Color(0xFFFF9800); // Orange
    }
  }
}