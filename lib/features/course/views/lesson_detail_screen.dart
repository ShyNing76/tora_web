import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/chapter.dart';
import '../widgets/lesson_content_tab.dart';
import '../widgets/lesson_summary_tab.dart';
import '../widgets/lesson_flashcard_tab.dart';
import '../widgets/lesson_quiz_tab.dart';
import '../widgets/lesson_ai_chat_tab.dart';
import 'quiz_detail_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final String courseTitle;
  final String courseId;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.courseTitle,
    required this.courseId,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _sidebarItems = [
    {
      'icon': Icons.play_circle_outline,
      'label': 'Nội dung bài học',
    },
    {
      'icon': Icons.summarize_outlined,
      'label': 'Tóm tắt bài học',
    },
    {
      'icon': Icons.quiz_outlined,
      'label': 'Flashcards',
    },
    {
      'icon': Icons.assignment_outlined,
      'label': 'Quiz bài học',
    },
    {
      'icon': Icons.smart_toy_outlined,
      'label': 'Hỏi đáp cùng Tora',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // If this is a quiz lesson, navigate to quiz detail screen directly
    if (widget.lesson.type == LessonType.quiz) {
      // Use Future.microtask to prevent build-time navigation
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetailScreen(lesson: widget.lesson),
          ),
        );
      });
      
      // Return a loading screen while navigating
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.textPrimaryColor,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.courseTitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              widget.lesson.title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                _showNavigationBottomSheet(context);
              },
              icon: Stack(
                children: [
                  const Icon(
                    Icons.menu,
                    color: AppColors.textPrimaryColor,
                  ),
                  if (_selectedIndex != 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Mở menu điều hướng',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.borderColor,
          ),
        ),
      ),
      body: _buildMainContent(),
    );
  }

  void _showNavigationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.lesson.type == LessonType.lesson
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : AppColors.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.lesson.type == LessonType.lesson
                          ? Icons.play_circle_outline
                          : Icons.quiz_outlined,
                      color: widget.lesson.type == LessonType.lesson
                          ? AppColors.primaryColor
                          : AppColors.warningColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lesson.type == LessonType.lesson 
                              ? 'Bài học' 
                              : 'Bài kiểm tra',
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.lesson.type == LessonType.lesson
                                ? AppColors.primaryColor
                                : AppColors.warningColor,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.lesson.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (widget.lesson.durationMinutes > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.lesson.durationMinutes} phút',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Navigation items
              ...List.generate(_sidebarItems.length, (index) {
                final item = _sidebarItems[index];
                final isSelected = _selectedIndex == index;
                
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Material(
                    color: isSelected 
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.primaryColor.withOpacity(0.2)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'],
                              color: isSelected 
                                  ? AppColors.primaryColor
                                  : AppColors.textSecondaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item['label'],
                                style: TextStyle(
                                  color: isSelected 
                                      ? AppColors.primaryColor
                                      : AppColors.textSecondaryColor,
                                  fontSize: 14,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: AppColors.primaryColor,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }



  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return LessonContentTab(
          lesson: widget.lesson,
          courseId: widget.courseId,
        );
      case 1:
        return LessonSummaryTab(
          lesson: widget.lesson,
          courseId: widget.courseId,
        );
      case 2:
        return LessonFlashcardTab(
          lesson: widget.lesson,
          courseId: widget.courseId,
        );
      case 3:
        return LessonQuizTab(
          lesson: widget.lesson,
          courseId: widget.courseId,
        );
      case 4:
        return LessonAiChatTab(lesson: widget.lesson);
      default:
        return LessonContentTab(
          lesson: widget.lesson,
          courseId: widget.courseId,
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}