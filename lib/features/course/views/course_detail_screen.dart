import 'package:flutter/material.dart';
import 'package:tora/core/utils/currency_utils.dart';
import '../../../core/constants/app_colors.dart';
import '../models/course.dart';
import '../models/chapter.dart';
import '../services/course_service.dart';
import '../widgets/course_detail_header.dart';
import '../widgets/chapter_card.dart';
import 'lesson_detail_screen.dart';
import 'quiz_detail_screen.dart';
import '../../payment/views/payment_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final CourseService _courseService = CourseService();
  List<Chapter> _chapters = [];
  List<bool> _expandedChapters = [];
  bool _isEnrolled = false;
  List<String> _completedLessonIds = [];
  bool _isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    _initializeChaptersFromCourse();
    _loadCourseProgress();
  }

  Future<void> _loadCourseProgress() async {
    setState(() {
      _isLoadingProgress = true;
    });

    final result = await _courseService.getCourseProgress(widget.course.id);
    
    if (result['success'] == true && result['isEnrolled'] == true) {
      // Parse completed lesson IDs from chapters array
      List<String> allCompletedLessonIds = [];
      final progressData = result['progressData'];
      
      if (progressData != null && progressData['chapters'] != null) {
        final chapters = progressData['chapters'] as List;
        for (var chapter in chapters) {
          if (chapter['completedLessonIds'] != null) {
            final completedIds = List<String>.from(chapter['completedLessonIds']);
            allCompletedLessonIds.addAll(completedIds);
          }
        }
      }
      
      setState(() {
        _isEnrolled = true;
        _completedLessonIds = allCompletedLessonIds;
        _isLoadingProgress = false;
      });
      
      print('📊 Enrolled: $_isEnrolled, Completed lessons: ${_completedLessonIds.length}');
      
      // Apply locking logic after loading progress
      _applyLessonLockingLogic();
    } else {
      setState(() {
        _isEnrolled = false;
        _completedLessonIds = [];
        _isLoadingProgress = false;
      });
      
      print('📊 Not enrolled in course');
    }
  }

  void _initializeChaptersFromCourse() {
    // Parse chapters from API data
    if (widget.course.chapters != null && widget.course.chapters!.isNotEmpty) {
      _chapters = (widget.course.chapters as List)
          .map((chapterJson) => Chapter.fromJson(chapterJson as Map<String, dynamic>))
          .toList();
      
      // Sort chapters by ordering
      _chapters.sort((a, b) => a.ordering.compareTo(b.ordering));
      
      // Add quiz as lesson to each chapter if quiz exists
      for (var chapter in _chapters) {
        if (chapter.quiz != null && chapter.quiz!.isActive) {
          var quizLesson = chapter.quiz!.toLesson();
          chapter.lessons.add(quizLesson);
          print('✅ Added quiz "${quizLesson.name}" (type: ${quizLesson.type}) to chapter "${chapter.name}"');
        }
      }
      
      _expandedChapters = List.generate(_chapters.length, (index) => index == 0);
    } else {
      // No chapters from API, initialize empty
      _chapters = [];
      _expandedChapters = [];
    }
  }

  void _applyLessonLockingLogic() {
    if (!_isEnrolled) {
      // If not enrolled, lock all lessons and quizzes
      return;
    }

    for (var chapter in _chapters) {
      // Check if all non-quiz lessons in this chapter are completed
      var nonQuizLessons = chapter.lessons
          .where((lesson) => lesson.type != LessonType.quiz)
          .toList();
      
      // Check if all non-quiz lessons are completed
      bool allNonQuizCompleted = nonQuizLessons.isEmpty || 
          nonQuizLessons.every((lesson) => _completedLessonIds.contains(lesson.id));
      
      // The lock status will be checked in ChapterCard and _onLessonTap
      // No need to modify lesson objects here
      if (!allNonQuizCompleted) {
        // Quiz is locked - handled in UI layer
      }
    }
    
    setState(() {});
  }

  void _toggleChapter(int index) {
    setState(() {
      _expandedChapters[index] = !_expandedChapters[index];
    });
  }

  void _onLessonTap(Lesson lesson) {
    // Check if user is enrolled first
    if (!_isEnrolled) {
      _showNotEnrolledDialog();
      return;
    }

    // Check if lesson is a quiz
    if (lesson.type == LessonType.quiz) {
      // Find the chapter containing this quiz
      Chapter? parentChapter;
      for (var chapter in _chapters) {
        if (chapter.lessons.any((l) => l.id == lesson.id)) {
          parentChapter = chapter;
          break;
        }
      }

      if (parentChapter != null) {
        // Check if all non-quiz lessons in this chapter are completed
        var nonQuizLessons = parentChapter.lessons
            .where((l) => l.type != LessonType.quiz)
            .toList();
        
        bool allNonQuizCompleted = nonQuizLessons.isEmpty || 
            nonQuizLessons.every((l) => _completedLessonIds.contains(l.id));
        
        if (!allNonQuizCompleted) {
          _showLockedQuizDialog();
          return;
        }
      }

      // Navigate to quiz detail screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizDetailScreen(
            lesson: lesson,
          ),
        ),
      );
    } else {
      // Navigate to lesson detail screen for regular lessons
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LessonDetailScreen(
            lesson: lesson,
            courseTitle: widget.course.title,
            courseId: widget.course.id,
          ),
        ),
      );
    }
  }

  void _showNotEnrolledDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chưa đăng ký khóa học'),
          content: const Text(
            'Bạn cần đăng ký khóa học này để có thể học các bài học.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enrollCourse();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đăng ký ngay'),
            ),
          ],
        );
      },
    );
  }

  void _showLockedQuizDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bài kiểm tra bị khóa'),
          content: const Text(
            'Bạn cần hoàn thành tất cả bài học trong chương này để có thể làm bài kiểm tra.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đã hiểu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Course Header
          SliverToBoxAdapter(
            child: CourseDetailHeader(course: widget.course),
          ),
          
          // Course Content Section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.playlist_play_rounded,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nội dung khóa học',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_chapters.length} chương',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Chapters List
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.backgroundColor,
              padding: const EdgeInsets.all(16),
              child: _isLoadingProgress
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      children: List.generate(_chapters.length, (index) {
                        return ChapterCard(
                          chapter: _chapters[index],
                          isExpanded: _expandedChapters[index],
                          onToggle: () => _toggleChapter(index),
                          onLessonTap: _onLessonTap,
                          isEnrolled: _isEnrolled,
                          completedLessonIds: _completedLessonIds,
                        );
                      }),
                    ),
            ),
          ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      
      // Floating Action Button (Start/Continue Learning)
      floatingActionButton: _isLoadingProgress
          ? null
          : (_isEnrolled
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // Find next lesson to continue
                    _continueNextLesson();
                  },
                  backgroundColor: AppColors.primaryColor,
                  label: const Text(
                    'Tiếp tục học',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                  ),
                )
              : FloatingActionButton.extended(
                  onPressed: () {
                    _enrollCourse();
                  },
                  backgroundColor: AppColors.successColor,
                  label: Text(
                    widget.course.isPaid 
                        ? 'Đăng ký học - ${CurrencyUtils.formatVND(widget.course.price)}'
                        : 'Đăng ký học miễn phí',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  icon: const Icon(
                    Icons.school,
                    color: Colors.white,
                  ),
                )),
    );
  }

  void  _continueNextLesson() {
    // Find first incomplete lesson
    for (var chapter in _chapters) {
      for (var lesson in chapter.lessons) {
        // Skip if lesson is already completed
        if (_completedLessonIds.contains(lesson.id)) {
          continue;
        }

        // If it's a quiz, check if all lessons in the chapter are completed
        if (lesson.type == LessonType.quiz) {
          var nonQuizLessons = chapter.lessons
              .where((l) => l.type != LessonType.quiz)
              .toList();
          
          bool allNonQuizCompleted = nonQuizLessons.isEmpty || 
              nonQuizLessons.every((l) => _completedLessonIds.contains(l.id));
          
          if (!allNonQuizCompleted) {
            continue; // Skip locked quiz
          }
        }

        // Found next lesson to continue
        _onLessonTap(lesson);
        return;
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bạn đã hoàn thành tất cả bài học!'),
      ),
    );
  }

  void _enrollCourse() {
    // If course is paid, show confirmation dialog first
    if (widget.course.isPaid && widget.course.price != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Xác nhận đăng ký'),
            content: Text(
              'Bạn có muốn đăng ký khóa học "${widget.course.name}" với giá ${CurrencyUtils.formatVND(widget.course.price)} không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate to payment screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        courseId: widget.course.id,
                        courseName: widget.course.name,
                        amount: widget.course.price!,
                      ),
                    ),
                  ).then((success) {
                    // If payment successful, reload course progress
                    if (success == true) {
                      _loadCourseProgress();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xác nhận'),
              ),
            ],
          );
        },
      );
      return;
    }
    
    // For free courses, show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng ký khóa học'),
          content: const Text('Bạn có muốn đăng ký khóa học miễn phí này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Handle free enrollment
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đăng ký khóa học thành công!'),
                  ),
                );
                // Reload progress
                _loadCourseProgress();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}