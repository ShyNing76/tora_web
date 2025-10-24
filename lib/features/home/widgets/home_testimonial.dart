import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';


class HomeTestimonial extends StatelessWidget {
  const HomeTestimonial({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Học sinh nói gì về ToraEdu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildTestimonialCard(
            name: 'Nguyễn Minh Anh',
            school: 'Lớp 12A1 - THPT Lê Quý Đôn',
            content: 'ToraEdu đã giúp mình cải thiện điểm Toán từ 6 lên 8.5 chỉ trong 2 tháng. AI giải thích rất dễ hiểu!',
            rating: 5,
          ),
          const SizedBox(height: 16),
          _buildTestimonialCard(
            name: 'Trần Văn Hùng',
            school: 'Lớp 11A3 - THPT Nguyễn Huệ',
            content: 'Mình thích nhất là tính năng gamification. Học như chơi game, có điểm số và huy hiệu.',
            rating: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String name,
    required String school,
    required String content,
    required int rating,
  }) {
    return Container(
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
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryColor, AppColors.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    Text(
                      school,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: AppColors.secondaryColor,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$content"',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryColor,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

}