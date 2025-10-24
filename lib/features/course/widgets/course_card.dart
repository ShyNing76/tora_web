import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/course.dart';
import '../../../core/utils/currency_utils.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.8),
                          AppColors.secondaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: course.imageUrl.isNotEmpty
                        ? Image.network(
                            course.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                          )
                        : _buildPlaceholderImage(),
                  ),
                ),
                // Price badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: course.isPaid ? AppColors.warningColor : AppColors.successColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course.isPaid ? '${CurrencyUtils.formatVND(course.price) ?? '0'}' : 'Miễn phí',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Course type badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          course.type.icon,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.type.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Enrolled badge
                if (course.isEnrolled)
                  Positioned(
                    bottom: 8,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.successColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Đã đăng ký',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Course info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level and rating row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getLevelColor(course.level),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          course.level.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            course.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    course.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Progress bar (if enrolled)
                  if (course.isEnrolled && course.progress != null)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tiến độ học',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                            Text(
                              '${(course.progress! * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: course.progress,
                          backgroundColor: AppColors.borderColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  // Course stats
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.totalHours}h',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.people,
                        size: 14,
                        color: AppColors.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${course.studentCount} học viên',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            course.type == CourseType.textbook 
                ? Icons.menu_book_rounded 
                : Icons.psychology_rounded,
            size: 48,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 8),
          Text(
            course.title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(CourseLevel level) {
    switch (level) {
      case CourseLevel.basic:
        return AppColors.basicLevelColor;
      case CourseLevel.intermediate:
        return AppColors.intermediateLevelColor;
      case CourseLevel.advanced:
        return AppColors.advancedLevelColor;
    }
  }
}