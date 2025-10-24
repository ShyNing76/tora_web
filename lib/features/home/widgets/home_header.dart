import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onLoginButtonPressed;
  final double loginButtonOpacity;

  const HomeHeader({
    super.key,
    required this.onLoginButtonPressed,
    required this.loginButtonOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/mascot/logo.png',
                width: 60,
                height: 60,
              ),
            ],
          ),
          GestureDetector(
            onTap: onLoginButtonPressed,
            child: AnimatedOpacity(
              opacity: loginButtonOpacity,
              duration: const Duration(milliseconds: 150),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}