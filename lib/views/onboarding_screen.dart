import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/onboarding_viewmodel.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Chào mừng đến với ToraEdu!',
      description: 'Trợ lý AI thông minh giúp bạn học tập hiệu quả và đạt kết quả cao trong các kỳ thi',
      image: 'tora_happy',
      primaryColor: AppColors.primaryColor,
      secondaryColor: AppColors.primaryLightColor,
    ),
    OnboardingData(
      title: 'Học tập cá nhân hóa',
      description: 'AI phân tích điểm mạnh, điểm yếu để tạo lộ trình học phù hợp với từng cá nhân',
      image: 'tora_note',
      primaryColor: AppColors.infoColor,
      secondaryColor: AppColors.successColor,
    ),
    OnboardingData(
      title: 'Gamification thú vị',
      description: 'Học như chơi game với hệ thống điểm số, huy hiệu và bảng xếp hạng',
      image: 'tora_cool',
      primaryColor: AppColors.warningColor,
      secondaryColor: AppColors.secondaryColor,
    ),
    OnboardingData(
      title: 'Kho tài liệu khổng lồ',
      description: 'Hàng nghìn câu hỏi, bài tập và video bài giảng chất lượng cao',
      image: 'tora_quiz',
      primaryColor: AppColors.successColor,
      secondaryColor: AppColors.mathColor,
    ),
    OnboardingData(
      title: 'Chinh phục tri thức?',
      description: 'Hãy bắt đầu hành trình học tập cùng ToraEdu ngay hôm nay!',
      image: 'tora_smart',
      primaryColor: AppColors.primaryColor,
      secondaryColor: AppColors.secondaryColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
          if (_currentPage < _onboardingData.length - 1)
            TextButton(
              onPressed: () {
                _pageController.animateToPage(
                  _onboardingData.length - 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text(
                'Bỏ qua',
                style: TextStyle(
                  color: AppColors.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated emoji/image
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        data.primaryColor.withOpacity(0.1),
                        data.secondaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    // child: Text(
                    //   data.image,
                    //   style: const TextStyle(fontSize: 80),
                    // ),
                    child: Image.asset(
                      'assets/images/mascot/${data.image}.png',
                      width: 140,
                      height: 140,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          
          // Title with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: data.primaryColor,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          
          // Description with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    data.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondaryColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? _onboardingData[_currentPage].primaryColor
                      : AppColors.textLightColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Navigation buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _onboardingData[_currentPage].primaryColor,
                      side: BorderSide(
                        color: _onboardingData[_currentPage].primaryColor,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Quay lại',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_currentPage < _onboardingData.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Complete onboarding and navigate to main app
                      final onboardingViewModel = Provider.of<OnboardingViewModel>(context, listen: false);
                      await onboardingViewModel.completeOnboarding();
                      
                      if (mounted) {
                        context.go('/home');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _onboardingData[_currentPage].primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    _currentPage < _onboardingData.length - 1
                        ? 'Tiếp tục'
                        : 'Bắt đầu ngay',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Skip to login option
          if (_currentPage == _onboardingData.length - 1)
            TextButton(
              onPressed: () async {
                // Complete onboarding and navigate to main app (will show login in home screen)
                final onboardingViewModel = Provider.of<OnboardingViewModel>(context, listen: false);
                await onboardingViewModel.completeOnboarding();
                
                if (mounted) {
                  context.go('/login');
                }
              },
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryColor,
                  ),
                  children: [
                    const TextSpan(text: 'Đã có tài khoản? '),
                    TextSpan(
                      text: 'Đăng nhập ngay',
                      style: TextStyle(
                        color: _onboardingData[_currentPage].primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final Color primaryColor;
  final Color secondaryColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.primaryColor,
    required this.secondaryColor,
  });
}