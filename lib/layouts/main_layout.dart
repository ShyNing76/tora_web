import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/home/viewmodels/home_viewmodel.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/courses')) return 1;
    if (location.startsWith('/progress')) return 2;
    if (location.startsWith('/exams')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/courses');
        break;
      case 2:
        context.go('/progress');
        break;
      case 3:
        context.go('/exams');
        break;
      case 4:
        // Profile tab only visible when logged in, so no auth check needed
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentIndex = _getCurrentIndex(context);

    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final isLoggedIn = authViewModel.isLoggedIn;

        // Build navigation items based on auth status
        List<Widget> navItems = [
          _buildNavItem(0, Icons.home_rounded, 'Trang chủ'),
          _buildNavItem(1, Icons.menu_book_rounded, 'Khóa học'),
          _buildNavItem(2, Icons.trending_up_rounded, 'Tiến độ'),
          _buildNavItem(3, Icons.assignment_rounded, 'Bài thi'),
          _buildNavItem(4, Icons.person_rounded, 'Hồ sơ'),
        ];

        // Only add Progress tab if logged in
        if (isLoggedIn) {
          return MultiProvider(
            providers: [ChangeNotifierProvider(create: (_) => HomeViewModel())],
            child: Scaffold(
              body: widget.child,
              bottomNavigationBar: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: navItems,
                ),
              ),
            ),
          );
        } else {
          // If not logged in, remove navigation bar
          navItems.clear();
          return 
          Scaffold(
            body: widget.child,
          );
        }
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.textLightColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
