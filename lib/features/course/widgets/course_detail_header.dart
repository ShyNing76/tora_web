import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/course.dart';

class CourseDetailHeader extends StatelessWidget {
  final Course course;

  const CourseDetailHeader({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Chi tiết khóa học',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Share course
                    },
                    icon: const Icon(Icons.favorite, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Course Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Title
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Course Description
                  Text(
                    course.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  Row(
                    children: [
                      _buildStatItem(
                        Icons.access_time_rounded,
                        '${course.totalHours}h',
                        'Thời lượng',
                      ),
                      const SizedBox(width: 20),
                      _buildStatItem(
                        Icons.people_rounded,
                        '${course.studentCount}',
                        'Học viên',
                      ),
                      const SizedBox(width: 20),
                      _buildStatItem(
                        Icons.star_rounded,
                        course.rating.toStringAsFixed(1),
                        'Đánh giá',
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

  Widget _buildPlaceholderIcon() {
    return Icon(
      course.type == CourseType.textbook 
          ? Icons.menu_book_rounded 
          : Icons.psychology_rounded,
      size: 50,
      color: Colors.white.withOpacity(0.8),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}