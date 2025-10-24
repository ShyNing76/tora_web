import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tora/features/course/models/course.dart';
import 'package:tora/features/course/views/course_detail_screen.dart';
import 'package:tora/layouts/main_layout.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/signup_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../layouts/auth_layout.dart';
import '../../features/profile/views/profile_screen.dart';
import '../../features/profile/views/settings_screen.dart';
import '../../features/course/views/courses_screen.dart';
import '../../features/exam/views/exams_screen.dart';
import '../../features/progress/views/progress_screen.dart';
import '../../views/splash_screen.dart';
import '../../views/onboarding_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Auth Routes - NO Bottom Navigation
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => AuthLayout(child: const LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => AuthLayout(child: const SignupScreen()),
      ),

      // Main App Routes - WITH Bottom Navigation
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => MainLayout(child: const HomeScreen()),
      ),
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) => MainLayout(child: const CoursesScreen()),
        routes: [
          GoRoute(
            path: 'detail',
            name: 'course_detail',
            builder: (context, state) => MainLayout(
              child: CourseDetailScreen(course: state.extra as Course),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => MainLayout(child: const ProgressScreen()),
      ),
      GoRoute(
        path: '/exams',
        name: 'exams',
        builder: (context, state) => MainLayout(child: const ExamsScreen()),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => MainLayout(child: const ProfileScreen()),
        routes: [
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) =>
                MainLayout(child: const SettingsScreen()),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final isLoggedIn = authViewModel.isLoggedIn;
      final isLoading = authViewModel.isLoading;
      final currentLocation = state.uri.toString();

      // Don't redirect while checking auth status
      if (isLoading) {
        return null;
      }

      // Allow these routes without authentication
      const publicRoutes = ['/splash', '/onboarding', '/login', '/signup'];
      if (publicRoutes.contains(currentLocation)) {
        return null;
      }

      // Profile route - only accessible when logged in
      if (!isLoggedIn &&
          (currentLocation.startsWith('/profile')) &&
          (currentLocation.startsWith('/progress'))) {
        return '/home';
      }

      // Other protected routes can be accessed but with limited functionality
      // The individual screens will handle showing login prompts for restricted features

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get context => navigatorKey.currentContext;

  void push(String routeName, {Object? arguments}) {
    if (context != null) {
      context!.push(routeName, extra: arguments);
    }
  }

  void pushReplacement(String routeName, {Object? arguments}) {
    if (context != null) {
      context!.pushReplacement(routeName, extra: arguments);
    }
  }

  void pop([Object? result]) {
    if (context != null) {
      context!.pop(result);
    }
  }

  void pushAndRemoveUntil(String routeName, {Object? arguments}) {
    if (context != null) {
      while (context!.canPop()) {
        context!.pop();
      }
      context!.pushReplacement(routeName, extra: arguments);
    }
  }
}
