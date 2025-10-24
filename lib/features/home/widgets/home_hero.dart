import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';

class HomeHero extends StatelessWidget {
  final VoidCallback onStartLearningButtonPressed;
  final double startLearningButtonOpacity;


  const HomeHero({
    super.key,
    required this.onStartLearningButtonPressed,
    required this.startLearningButtonOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.primaryDarkColor],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/mascot/tora_smart.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 16),
          const Text(
            'Trợ lý AI với bản lĩnh Hổ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Đồng hành cùng bạn chinh phục tri thức và tương lai',
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AnimatedOpacity(
                  opacity: startLearningButtonOpacity,
                  duration: const Duration(milliseconds: 150),
                  child: ElevatedButton(
                    onPressed: onStartLearningButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Bắt đầu học ngay',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
