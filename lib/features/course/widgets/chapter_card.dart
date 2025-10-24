import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/chapter.dart';

class ChapterCard extends StatefulWidget {
  final Chapter chapter;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(Lesson) onLessonTap;
  final bool isEnrolled;
  final List<String> completedLessonIds;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.isExpanded,
    required this.onToggle,
    required this.onLessonTap,
    this.isEnrolled = false,
    this.completedLessonIds = const [],
  });

  @override
  State<ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<ChapterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    if (widget.isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ChapterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        children: [
          // Chapter Header
          InkWell(
            onTap: widget.onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Chapter Number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getChapterStatusColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.chapter.order}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Chapter Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chapter.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Progress and Duration
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 16,
                              color: AppColors.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.chapter.lessons.length} bài',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.chapter.totalDuration}p',
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
                  
                  // Progress Circle and Arrow
                  Column(
                    children: [
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          value: _calculateProgress(),
                          strokeWidth: 3,
                          backgroundColor: AppColors.borderColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedRotation(
                        turns: widget.isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Lessons List
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _animation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: widget.chapter.lessons
                    .map((lesson) => _buildLessonTile(lesson))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonTile(Lesson lesson) {
    // Check if lesson is completed
    bool isCompleted = widget.completedLessonIds.contains(lesson.id);
    
    // Check if lesson is locked
    bool isLocked = !widget.isEnrolled;
    
    // For quiz lessons, check if all non-quiz lessons in chapter are completed
    if (widget.isEnrolled && lesson.type == LessonType.quiz) {
      var nonQuizLessons = widget.chapter.lessons
          .where((l) => l.type != LessonType.quiz)
          .toList();
      
      var completedNonQuizLessons = nonQuizLessons
          .where((l) => widget.completedLessonIds.contains(l.id))
          .toList();
      
      bool allNonQuizCompleted = nonQuizLessons.isEmpty || 
          nonQuizLessons.every((l) => widget.completedLessonIds.contains(l.id));
      
      isLocked = !allNonQuizCompleted;
      
      // Debug log for quiz lessons
      if (lesson.type == LessonType.quiz) {
        print('🔍 Quiz "${lesson.title}" in chapter "${widget.chapter.title}":');
        print('   - Total non-quiz lessons: ${nonQuizLessons.length}');
        print('   - Completed non-quiz lessons: ${completedNonQuizLessons.length}');
        print('   - All completed: $allNonQuizCompleted');
        print('   - Is locked: $isLocked');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppColors.successColor.withOpacity(0.1)
            : isLocked
                ? AppColors.borderColor.withOpacity(0.5)
                : AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted 
              ? AppColors.successColor.withOpacity(0.3)
              : AppColors.borderColor,
        ),
      ),
      child: InkWell(
        onTap: isLocked ? null : () => widget.onLessonTap(lesson),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Lesson Status Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getLessonStatusColor(isCompleted, isLocked),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getLessonStatusIcon(lesson, isCompleted, isLocked),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              
              // Lesson Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isLocked 
                            ? AppColors.textSecondaryColor 
                            : AppColors.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textSecondaryColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${lesson.durationMinutes} phút',
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
              
              // Review Button (if completed)
              if (isCompleted)
                TextButton(
                  onPressed: () => widget.onLessonTap(lesson),
                  child: const Text(
                    'Xem lại',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getChapterStatusColor() {
    double progress = _calculateProgress();
    if (progress >= 1.0) {
      return AppColors.successColor;
    } else if (progress > 0) {
      return AppColors.warningColor;
    } else {
      return AppColors.primaryColor;
    }
  }

  double _calculateProgress() {
    if (widget.chapter.lessons.isEmpty) return 0.0;
    int completedCount = widget.chapter.lessons
        .where((lesson) => widget.completedLessonIds.contains(lesson.id))
        .length;
    return completedCount / widget.chapter.lessons.length;
  }

  Color _getProgressColor() {
    double progress = _calculateProgress();
    if (progress >= 1.0) {
      return AppColors.successColor;
    } else if (progress > 0) {
      return AppColors.warningColor;
    } else {
      return AppColors.primaryColor;
    }
  }

  Color _getLessonStatusColor(bool isCompleted, bool isLocked) {
    if (isLocked) {
      return AppColors.textSecondaryColor;
    } else if (isCompleted) {
      return AppColors.successColor;
    } else {
      return AppColors.primaryColor;
    }
  }

  IconData _getLessonStatusIcon(Lesson lesson, bool isCompleted, bool isLocked) {
    if (isLocked) {
      return Icons.lock;
    } else if (isCompleted) {
      return Icons.check;
    } else if (lesson.type == LessonType.quiz) {
      return Icons.quiz;
    } else {
      return Icons.play_arrow;
    }
  }
}