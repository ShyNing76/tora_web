import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tora/features/home/widgets/home_cta.dart';
import 'package:tora/features/home/widgets/home_features.dart';
import 'package:tora/features/home/widgets/home_header.dart';
import 'package:tora/features/home/widgets/home_hero.dart';
import 'package:tora/features/home/widgets/home_subjects.dart';
import 'package:tora/features/home/widgets/home_testimonial.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/views/login_screen.dart';
import '../../auth/views/signup_screen.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'logged_in_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _loginButtonOpacity = 1.0;
  double _signupButtonOpacity = 1.0;
  double _startLearningButtonOpacity = 1.0;

  void _onLoginButtonPressed() async {
    // Thêm hiệu ứng opacity
    setState(() {
      _loginButtonOpacity = 0.5;
    });

    // Đợi một chút để hiệu ứng được nhìn thấy
    await Future.delayed(const Duration(milliseconds: 150));

    // Reset opacity
    setState(() {
      _loginButtonOpacity = 1.0;
    });

    // Navigate đến login screen
    if (mounted) {
      context.push('/login');      
    }
  }

  void _onSignupButtonPressed() async {
    // Thêm hiệu ứng opacity
    setState(() {
      _signupButtonOpacity = 0.5;
    });

    // Đợi một chút để hiệu ứng được nhìn thấy
    await Future.delayed(const Duration(milliseconds: 150));

    // Reset opacity
    setState(() {
      _signupButtonOpacity = 1.0;
    });

    // Navigate đến signup screen
    if (mounted) {
      context.push('/signup');
    }
  }

  void _onStartLearningButtonPressed() async {
    // Thêm hiệu ứng opacity
    setState(() {
      _startLearningButtonOpacity = 0.5;
    });

    // Đợi một chút để hiệu ứng được nhìn thấy
    await Future.delayed(const Duration(milliseconds: 150));

    // Reset opacity
    setState(() {
      _startLearningButtonOpacity = 1.0;
    });

    // Navigate đến signup screen (vì "Bắt đầu học ngay" nghĩa là đăng ký)
    if (mounted) {
      context.push('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        print('🏠 HomeScreen rebuild - isLoggedIn: ${authViewModel.isLoggedIn}');
        
        // If user is logged in, show the logged in home screen
        if (authViewModel.isLoggedIn) {
          print('✅ Showing LoggedInHomeScreen');
          return const LoggedInHomeScreen();
        }
        
        print('📄 Showing landing page');
        // Otherwise show the landing page
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HomeHeader(
                    onLoginButtonPressed: _onLoginButtonPressed,
                    loginButtonOpacity: _loginButtonOpacity,
                  ),
                  HomeHero(
                    onStartLearningButtonPressed: _onStartLearningButtonPressed,
                    startLearningButtonOpacity: _startLearningButtonOpacity,
                  ),
                  const HomeFeatures(),
                  const HomeSubjects(),
                  const HomeTestimonial(), 
                  HomeCTA(
                    onSignupButtonPressed: _onSignupButtonPressed,
                    signupButtonOpacity: _signupButtonOpacity,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
