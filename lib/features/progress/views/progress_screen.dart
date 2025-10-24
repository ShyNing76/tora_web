import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/progress.dart';
import '../services/stats_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final StatsService _statsService = StatsService();
  
  UserProgress? _userProgress;
  Map<String, dynamic>? _statsData;
  Map<String, dynamic>? _weeklyLessonsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Load stats from API
    final result = await _statsService.getMyStats();

    if (result['success'] == true && mounted) {
      // Load weekly lessons progress
      final weeklyResult = await _statsService.getWeeklyLessonsProgress();
      
      setState(() {
        _statsData = result['data'];
        _weeklyLessonsData = weeklyResult['success'] == true 
            ? weeklyResult['data'] 
            : null;
        _userProgress = _createMockProgress(); // Keep mock for now
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Không thể tải dữ liệu';
      });
    }
  }

  UserProgress _createMockProgress() {
    return UserProgress(
      userId: 'user-1',
      totalCoursesEnrolled: 8,
      coursesCompleted: 3,
      totalLessonsCompleted: 45,
      totalQuizzesTaken: 25,
      totalExamsTaken: 5,
      averageQuizScore: 85.5,
      averageExamScore: 78.2,
      totalStudyTimeMinutes: 1260, // 21 hours
      currentStreak: 7,
      longestStreak: 15,
      weeklyProgress: [
        WeeklyProgress(
          weekStart: DateTime.now().subtract(const Duration(days: 42)),
          lessonsCompleted: 3,
          quizzesTaken: 2,
          studyTimeMinutes: 120,
          averageScore: 75.0,
        ),
        WeeklyProgress(
          weekStart: DateTime.now().subtract(const Duration(days: 35)),
          lessonsCompleted: 5,
          quizzesTaken: 3,
          studyTimeMinutes: 180,
          averageScore: 80.5,
        ),
        WeeklyProgress(
          weekStart: DateTime.now().subtract(const Duration(days: 28)),
          lessonsCompleted: 7,
          quizzesTaken: 4,
          studyTimeMinutes: 200,
          averageScore: 85.0,
        ),
        WeeklyProgress(
          weekStart: DateTime.now().subtract(const Duration(days: 21)),
          lessonsCompleted: 6,
          quizzesTaken: 5,
          studyTimeMinutes: 240,
          averageScore: 88.2,
        ),
        WeeklyProgress(
          weekStart: DateTime.now().subtract(const Duration(days: 14)),
          lessonsCompleted: 8,
          quizzesTaken: 4,
          studyTimeMinutes: 220,
          averageScore: 86.5,
        ),
        WeeklyProgress(
          weekStart: DateTime.now().subtract(const Duration(days: 7)),
          lessonsCompleted: 12,
          quizzesTaken: 6,
          studyTimeMinutes: 300,
          averageScore: 90.0,
        ),
      ],
      subjectProgress: [
        SubjectProgress(
          subject: 'Toán học',
          totalLessons: 20,
          completedLessons: 15,
          totalQuizzes: 10,
          completedQuizzes: 8,
          averageScore: 88.5,
          color: '#4CAF50',
        ),
        SubjectProgress(
          subject: 'Vật lý',
          totalLessons: 15,
          completedLessons: 8,
          totalQuizzes: 8,
          completedQuizzes: 5,
          averageScore: 82.0,
          color: '#2196F3',
        ),
        SubjectProgress(
          subject: 'Hóa học',
          totalLessons: 12,
          completedLessons: 10,
          totalQuizzes: 6,
          completedQuizzes: 6,
          averageScore: 85.8,
          color: '#FF9800',
        ),
        SubjectProgress(
          subject: 'Kỹ năng mềm',
          totalLessons: 8,
          completedLessons: 6,
          totalQuizzes: 4,
          completedQuizzes: 3,
          averageScore: 90.2,
          color: '#9C27B0',
        ),
      ],
      recentActivities: [
        RecentActivity(
          id: 'act-1',
          title: 'Hoàn thành bài học "Đạo hàm hàm số"',
          description: 'Khóa học Toán học lớp 12',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: ActivityType.lessonCompleted,
        ),
        RecentActivity(
          id: 'act-2',
          title: 'Đạt 95% trong bài kiểm tra Vật lý',
          description: 'Chương Điện học - Định luật Ohm',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          type: ActivityType.quizCompleted,
        ),
        RecentActivity(
          id: 'act-3',
          title: 'Mở khóa thành tựu "Cao thủ Quiz"',
          description: 'Đạt trên 90% trong 5 bài quiz liên tiếp',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          type: ActivityType.achievementEarned,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
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
                  onPressed: _loadProgressData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom SliverAppBar with gradient similar to CoursesScreen
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryDarkColor,
                      AppColors.secondaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background decorative circles
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              right: -50,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -30,
                              left: -30,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 80,
                              left: 20,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Header content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/mascot/tora_cool.png',
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tiến độ học tập',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Theo dõi hành trình của bạn',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overview stats
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: _buildOverviewStats(),
            ),
          ),

          // Progress charts
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildProgressCharts(),
            ),
          ),

          // Subject progress
          // SliverToBoxAdapter(
          //   child: Container(
          //     padding: const EdgeInsets.all(16),
          //     child: _buildSubjectProgress(),
          //   ),
          // ),

          // Recent activities
          // SliverToBoxAdapter(
          //   child: Container(
          //     padding: const EdgeInsets.all(16),
          //     child: _buildRecentActivities(),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats() {
    if (_statsData == null) return const SizedBox();

    final totalCoursesLearned = _statsData!['totalCoursesLearned'] ?? 0;
    final totalEnrolledCourses = _statsData!['totalEnrolledCourses'] ?? 0;
    final totalQuizzesTaken = _statsData!['totalQuizzesTaken'] ?? 0;
    final totalQuizzesPass = _statsData!['totalQuizzesPass'] ?? 0;
    final totalQuizzesFail = _statsData!['totalQuizzesFail'] ?? 0;
    final totalLessonsLearned = _statsData!['totalLessonsLearned'] ?? 0;
    final totalLessonsInEnrolledCourses = _statsData!['totalLessonsInEnrolledCourses'] ?? 0;
    final currentStreak = _statsData!['currentStreak'] ?? 0;
    final bestStreak = _statsData!['bestStreak'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tổng quan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Khóa học',
                '$totalCoursesLearned/$totalEnrolledCourses',
                'Đã hoàn thành',
                Icons.school,
                AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Bài thi / kiểm tra',
                '$totalQuizzesTaken',
                'Đạt: $totalQuizzesPass · Trượt: $totalQuizzesFail',
                Icons.assignment_outlined,
                AppColors.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Bài học',
                '$totalLessonsLearned/$totalLessonsInEnrolledCourses',
                'Đã hoàn thành',
                Icons.menu_book,
                AppColors.infoColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Chuỗi học tập',
                '$currentStreak ngày',
                'Tốt nhất: $bestStreak ngày',
                Icons.local_fire_department,
                AppColors.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCharts() {
    if (_userProgress == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Biểu đồ tiến độ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hoạt động học tập 7 ngày qua',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  if (_weeklyLessonsData != null && _weeklyLessonsData!.isNotEmpty)
                    Text(
                      _getDateRangeText(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _buildWeeklyChart(),
            ],
          ),
        ),
      ],
    );
  }

  String _getDateRangeText() {
    if (_weeklyLessonsData == null || _weeklyLessonsData!.isEmpty) {
      return '';
    }

    final dates = _weeklyLessonsData!.keys.toList();
    dates.sort();

    final startDate = DateTime.parse(dates.first);
    final endDate = DateTime.parse(dates.last);

    final startFormatted = '${startDate.day}/${startDate.month}';
    final endFormatted = '${endDate.day}/${endDate.month}';

    return '$startFormatted - $endFormatted';
  }

  Widget _buildWeeklyChart() {
    if (_weeklyLessonsData == null || _weeklyLessonsData!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Chưa có dữ liệu học tập',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ),
      );
    }

    // Convert API data to list of entries
    final entries = _weeklyLessonsData!.entries.toList();
    
    // Sort by date
    entries.sort((a, b) => a.key.compareTo(b.key));
    
    // Get max value for scaling
    final maxLessons = entries
        .map((e) => (e.value as num).toInt())
        .reduce((a, b) => a > b ? a : b);
    
    final maxHeight = maxLessons > 0 ? maxLessons : 1;

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((dateEntry) {
          final date = dateEntry.key;
          final lessonsCount = (dateEntry.value as num).toInt();
          
          // Calculate bar height
          final height = lessonsCount > 0
              ? (lessonsCount / maxHeight * 150).clamp(10.0, 150.0)
              : 10.0;
          
          // Format date to show day name (T2, T3, T4...)
          final dateTime = DateTime.parse(date);
          final weekday = dateTime.weekday;
          final dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
          final dayName = dayNames[weekday % 7];
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$lessonsCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: lessonsCount > 0 
                      ? AppColors.textPrimaryColor 
                      : AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: height,
                decoration: BoxDecoration(
                  gradient: lessonsCount > 0
                      ? LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.6),
                          ],
                        )
                      : null,
                  color: lessonsCount == 0 ? Colors.grey[300] : null,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dayName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubjectProgress() {
    if (_userProgress == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Tiến độ theo môn học',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ..._userProgress!.subjectProgress
            .map(
              (subject) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subject.subject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                        Text(
                          '${subject.averageScore.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getScoreColor(subject.averageScore),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bài học: ${subject.completedLessons}/${subject.totalLessons}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value:
                                    subject.completedLessons /
                                    subject.totalLessons,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(
                                    int.parse(
                                      subject.color.replaceFirst('#', '0xFF'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quiz: ${subject.completedQuizzes}/${subject.totalQuizzes}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value:
                                    subject.completedQuizzes /
                                    subject.totalQuizzes,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(
                                    int.parse(
                                      subject.color.replaceFirst('#', '0xFF'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return AppColors.successColor;
    if (score >= 70) return AppColors.warningColor;
    return AppColors.errorColor;
  }

  Widget _buildRecentActivities() {
    if (_userProgress == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Hoạt động gần đây',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ..._userProgress!.recentActivities
            .map(
              (activity) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: activity.type.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        activity.type.icon,
                        color: activity.type.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatTimeAgo(activity.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}
