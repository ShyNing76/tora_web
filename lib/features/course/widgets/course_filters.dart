import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/course.dart';

class CourseFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CourseFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondaryColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class CourseFiltersSection extends StatelessWidget {
  final CourseType? selectedType;
  final CourseLevel? selectedLevel;
  final bool? showPaidOnly;
  final bool? showEnrolledOnly;
  final Function(CourseType?) onTypeChanged;
  final Function(CourseLevel?) onLevelChanged;
  final Function(bool?) onPaidFilterChanged;
  final Function(bool?) onEnrolledFilterChanged;
  final VoidCallback onClearFilters;

  const CourseFiltersSection({
    super.key,
    this.selectedType,
    this.selectedLevel,
    this.showPaidOnly,
    this.showEnrolledOnly,
    required this.onTypeChanged,
    required this.onLevelChanged,
    required this.onPaidFilterChanged,
    required this.onEnrolledFilterChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Xóa tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Course Type Filter
          const Text(
            'Loại khóa học',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CourseFilterChip(
                  label: 'Tất cả',
                  isSelected: selectedType == null,
                  onTap: () => onTypeChanged(null),
                ),
                ...CourseType.values.map((type) => CourseFilterChip(
                  label: type.displayName,
                  isSelected: selectedType == type,
                  onTap: () => onTypeChanged(type),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Course Level Filter
          const Text(
            'Độ khó',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CourseFilterChip(
                  label: 'Tất cả',
                  isSelected: selectedLevel == null,
                  onTap: () => onLevelChanged(null),
                ),
                ...CourseLevel.values.map((level) => CourseFilterChip(
                  label: level.displayName,
                  isSelected: selectedLevel == level,
                  onTap: () => onLevelChanged(level),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Other Filters
          const Text(
            'Trạng thái',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CourseFilterChip(
                  label: 'Miễn phí',
                  isSelected: showPaidOnly == false,
                  onTap: () => onPaidFilterChanged(showPaidOnly == false ? null : false),
                ),
                CourseFilterChip(
                  label: 'Trả phí',
                  isSelected: showPaidOnly == true,
                  onTap: () => onPaidFilterChanged(showPaidOnly == true ? null : true),
                ),
                CourseFilterChip(
                  label: 'Đã đăng ký',
                  isSelected: showEnrolledOnly == true,
                  onTap: () => onEnrolledFilterChanged(showEnrolledOnly == true ? null : true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}