import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/course.dart';
import '../widgets/course_card.dart';
import '../widgets/course_filters.dart';
import '../../../widgets/login_prompt_widget.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/course_viewmodel.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  CourseType? _selectedType;
  CourseLevel? _selectedLevel;
  bool? _showPaidOnly;
  bool? _showEnrolledOnly;
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    // Fetch courses when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCourses();
    });
  }

  Future<void> _fetchCourses() async {
    final courseViewModel = Provider.of<CourseViewModel>(context, listen: false);
    
    // Map CourseType to API attributes
    String? typeParam;
    if (_selectedType == CourseType.textbook) {
      typeParam = 'TextBook';
    } else if (_selectedType == CourseType.softSkills) {
      typeParam = 'SoftSkills';
    }
    
    // Map CourseLevel to API level
    String? levelParam;
    if (_selectedLevel == CourseLevel.basic) {
      levelParam = 'Easy';
    } else if (_selectedLevel == CourseLevel.intermediate) {
      levelParam = 'Medium';
    } else if (_selectedLevel == CourseLevel.advanced) {
      levelParam = 'Hard';
    }
    
    await courseViewModel.fetchCourses(
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      type: typeParam,
      level: levelParam,
    );
  }

  List<Course> _getFilteredCourses(List<Course> courses) {
    List<Course> filtered = List.from(courses);

    // Paid filter
    if (_showPaidOnly != null) {
      filtered = filtered.where((course) => course.isPaid == _showPaidOnly).toList();
    }

    // Enrolled filter
    if (_showEnrolledOnly == true) {
      filtered = filtered.where((course) => course.isEnrolled).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedLevel = null;
      _showPaidOnly = null;
      _showEnrolledOnly = null;
      _searchController.clear();
      _searchQuery = '';
    });
    // Refetch courses after clearing filters
    _fetchCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<CourseViewModel>(
        builder: (context, courseViewModel, child) {
          // Apply local filters on top of API results
          final courses = _getFilteredCourses(courseViewModel.courses);
          
          return CustomScrollView(
        slivers: [
          // Custom SliverAppBar with gradient
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
                                'assets/images/mascot/tora_chat.png',
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Khóa học',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Khám phá và học tập cùng Tora',
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
                  hintText: 'Tìm kiếm khóa học...',
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
                  // Debounce search - fetch after user stops typing
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchQuery == value) {
                      _fetchCourses();
                    }
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
                child: CourseFiltersSection(
                  selectedType: _selectedType,
                  selectedLevel: _selectedLevel,
                  showPaidOnly: _showPaidOnly,
                  showEnrolledOnly: _showEnrolledOnly,
                  onTypeChanged: (type) {
                    setState(() => _selectedType = type);
                    _fetchCourses();
                  },
                  onLevelChanged: (level) {
                    setState(() => _selectedLevel = level);
                    _fetchCourses();
                  },
                  onPaidFilterChanged: (paid) => setState(() => _showPaidOnly = paid),
                  onEnrolledFilterChanged: (enrolled) => setState(() => _showEnrolledOnly = enrolled),
                  onClearFilters: _clearFilters,
                ),
              ),
            ),
          
          // Loading indicator
          if (courseViewModel.isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          
          // Error message
          if (courseViewModel.errorMessage != null && !courseViewModel.isLoading)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        courseViewModel.errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchCourses,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Courses list
          if (!courseViewModel.isLoading && courseViewModel.errorMessage == null)
            courses.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = courses[index];
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            index == 0 ? 16 : 0,
                            16,
                            index == courses.length - 1 ? 16 : 0,
                          ),
                          child: CourseCard(
                            course: course,
                            onTap: () => _onCourseCardTapped(course),
                          ),
                        );
                      },
                      childCount: courses.length,
                    ),
                  ),
          ],
        );
        },
      ),
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
              Icons.search_off_rounded,
              size: 80,
              color: AppColors.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy khóa học nào',
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

  void _onCourseCardTapped(Course course) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    if (authViewModel.isLoggedIn) {
      // Navigate to course detail screen
      context.pushNamed('course_detail', extra: course);
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
          message: 'Bạn phải đăng nhập để xem chi tiết khóa học',
          description: 'Đăng nhập để xem nội dung chi tiết, tham gia khóa học và theo dõi tiến độ học tập.',
        ),
      ),
    );
  }
}