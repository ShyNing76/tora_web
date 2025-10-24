import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/exam.dart';
import '../widgets/exam_card.dart';
import '../../../widgets/login_prompt_widget.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'exam_detail_screen.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ExamStatus? _selectedStatus;
  String? _selectedSubject;
  bool _isFilterVisible = false;

  // Mock data for exams
  List<Exam> _allExams = [];

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  void _initializeMockData() {
    _allExams = [
      Exam(
        id: 'exam-1',
        title: 'Kiểm tra giữa kỳ - Toán học',
        description: 'Bài kiểm tra giữa kỳ môn Toán học lớp 10, chương Hàm số và Đồ thị',
        courseId: 'course-1',
        courseName: 'Toán học lớp 10 - Hàm số và đồ thị',
        subject: 'Toán học',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 9)),
        duration: 90,
        totalQuestions: 30,
        passingScore: 70,
        isEnrolled: true,
        difficulty: ExamDifficulty.medium,
        topics: ['Hàm số', 'Đồ thị', 'Tính chất hàm số'],
        instructions: 'Bài thi gồm 30 câu hỏi trắc nghiệm, thời gian làm bài 90 phút.',
      ),
      Exam(
        id: 'exam-2',
        title: 'Bài thi cuối kỳ - Vật lý',
        description: 'Bài thi cuối kỳ môn Vật lý lớp 11, chương Điện học',
        courseId: 'course-2',
        courseName: 'Vật lý 11 - Điện học',
        subject: 'Vật lý',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 14)),
        duration: 120,
        totalQuestions: 40,
        passingScore: 75,
        isEnrolled: false,
        difficulty: ExamDifficulty.hard,
        topics: ['Dòng điện', 'Điện trở', 'Định luật Ohm', 'Mạch điện'],
        instructions: 'Bài thi gồm 40 câu hỏi, thời gian 120 phút. Cần đăng ký khóa học trước khi thi.',
      ),
      Exam(
        id: 'exam-3',
        title: 'Kiểm tra - Hóa học hữu cơ',
        description: 'Bài kiểm tra chương Hợp chất hữu cơ',
        courseId: 'course-4',
        courseName: 'Hóa học 12 - Hóa hữu cơ',
        subject: 'Hóa học',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        duration: 75,
        totalQuestions: 25,
        passingScore: 70,
        isEnrolled: true,
        isCompleted: true,
        lastScore: 85.5,
        lastAttemptDate: DateTime.now().subtract(const Duration(hours: 2)),
        currentAttempts: 1,
        difficulty: ExamDifficulty.medium,
        topics: ['Hợp chất hữu cơ', 'Phản ứng hữu cơ'],
        instructions: 'Bài kiểm tra 25 câu hỏi về hóa hữu cơ, thời gian 75 phút.',
      ),
      Exam(
        id: 'exam-4',
        title: 'Đánh giá kỹ năng giao tiếp',
        description: 'Bài thi đánh giá kỹ năng giao tiếp và thuyết trình',
        courseId: 'course-3',
        courseName: 'Kỹ năng giao tiếp hiệu quả',
        subject: 'Kỹ năng mềm',
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        duration: 60,
        totalQuestions: 20,
        passingScore: 65,
        isEnrolled: true,
        currentAttempts: 2,
        maxAttempts: 3,
        difficulty: ExamDifficulty.easy,
        topics: ['Giao tiếp', 'Thuyết trình', 'Kỹ năng mềm'],
        instructions: 'Bài thi đánh giá kỹ năng giao tiếp qua 20 tình huống thực tế.',
      ),
    ];
  }

  List<Exam> get _filteredExams {
    List<Exam> filtered = List.from(_allExams);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((exam) {
        return exam.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               exam.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               exam.courseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               exam.subject.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((exam) => exam.status == _selectedStatus).toList();
    }

    // Subject filter
    if (_selectedSubject != null) {
      filtered = filtered.where((exam) => exam.subject == _selectedSubject).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedSubject = null;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExams = _filteredExams;
    final subjects = _allExams.map((e) => e.subject).toSet().toList();

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
                                'assets/images/mascot/tora_quiz.png',
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bài thi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Thử thách bản thân cùng Tora',
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
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _isFilterVisible ? Icons.filter_list_off : Icons.tune_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFilterVisible = !_isFilterVisible;
                    });
                  },
                ),
              ),
            ],
          ),
          
          // Search bar section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài thi...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textSecondaryColor),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          
          // Filters section
          if (_isFilterVisible)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: _buildFilters(subjects),
              ),
            ),
          
          // Quick stats
          // SliverToBoxAdapter(
          //   child: Container(
          //     padding: const EdgeInsets.all(16),
          //     child: _buildQuickStats(),
          //   ),
          // ),
          
          // Exams list
          filteredExams.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exam = filteredExams[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          index == 0 ? 0 : 0,
                          16,
                          index == filteredExams.length - 1 ? 16 : 0,
                        ),
                        child: ExamCard(
                          exam: exam,
                          onTap: () => _onExamCardTapped(exam),
                        ),
                      );
                    },
                    childCount: filteredExams.length,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<String> subjects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bộ lọc',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        // Status filter
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Tất cả'),
              selected: _selectedStatus == null,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = selected ? null : _selectedStatus;
                });
              },
            ),
            ...ExamStatus.values.map((status) {
              String label = '';
              switch (status) {
                case ExamStatus.notEnrolled:
                  label = 'Chưa đăng ký';
                  break;
                case ExamStatus.available:
                  label = 'Có thể thi';
                  break;
                case ExamStatus.unavailable:
                  label = 'Chưa mở';
                  break;
                case ExamStatus.completed:
                  label = 'Đã hoàn thành';
                  break;
                case ExamStatus.outOfAttempts:
                  label = 'Hết lượt thi';
                  break;
              }
              return FilterChip(
                label: Text(label),
                selected: _selectedStatus == status,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? status : null;
                  });
                },
              );
            }).toList(),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Subject filter
        Wrap(
          spacing: 8,
          children: subjects.map((subject) {
            return FilterChip(
              label: Text(subject),
              selected: _selectedSubject == subject,
              onSelected: (selected) {
                setState(() {
                  _selectedSubject = selected ? subject : null;
                });
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 12),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Xóa tất cả bộ lọc'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: AppColors.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy bài thi nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Xóa tất cả bộ lọc'),
            ),
          ],
        ),
      ),
    );
  }

  void _onExamCardTapped(Exam exam) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    if (authViewModel.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExamDetailScreen(exam: exam),
        ),
      );
    } else {
      // Show login prompt dialog
      _showLoginPromptDialog();
    }
  }
  
  void _showLoginPromptDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const LoginPromptWidget(
          message: 'Bạn phải đăng nhập để tham gia bài thi',
          description: 'Đăng nhập để xem chi tiết bài thi, tham gia làm bài và theo dõi kết quả.',
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Đã hoàn thành',
            value: '12',
            icon: Icons.check_circle_rounded,
            color: AppColors.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Chưa làm',
            value: '5',
            icon: Icons.pending_rounded,
            color: AppColors.warningColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Điểm TB',
            value: '8.2',
            icon: Icons.star_rounded,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
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
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}