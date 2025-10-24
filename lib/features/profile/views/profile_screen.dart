import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            // final user = authViewModel.user;
            
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, authViewModel),
                  const SizedBox(height: 20),
                  _buildStats(),
                  _buildMenuItems(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthViewModel authViewModel) {
    final user = authViewModel.user;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User avatar and info
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.asset(
                            'assets/images/mascot/tora_happy.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primaryColor,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'user@example.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Settings button
              IconButton(
                onPressed: () {
                  // Navigate to settings
                  context.push('/profile/settings');
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.user;
        final currentStreak = user?.currentStreak ?? 0;
        final bestStreak = user?.bestStreak ?? 0;
        
        return Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Khóa học',
                  '8',
                  Icons.school_outlined,
                  AppColors.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '$currentStreak ngày',
                  Icons.local_fire_department_outlined,
                  AppColors.errorColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Best',
                  '$bestStreak ngày',
                  Icons.emoji_events_outlined,
                  AppColors.secondaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Thông tin cá nhân',
        'subtitle': 'Chỉnh sửa hồ sơ và thông tin',
        'color': AppColors.infoColor,
        'route': null,
      },
      {
        'icon': Icons.school_outlined,
        'title': 'Khóa học của tôi',
        'subtitle': 'Xem tiến độ và kết quả học tập',
        'color': AppColors.successColor,
        'route': '/courses',
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Cài đặt',
        'subtitle': 'Tùy chỉnh ứng dụng',
        'color': AppColors.textSecondaryColor,
        'route': '/profile/settings',
      },
      {
        'icon': Icons.logout,
        'title': 'Đăng xuất',
        'subtitle': 'Thoát khỏi tài khoản',
        'color': AppColors.errorColor,
        'route': 'logout',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: menuItems.map((item) => _buildMenuItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    return InkWell(
      onTap: () => _handleMenuItemTap(context, item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textLightColor,
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleMenuItemTap(BuildContext context, Map<String, dynamic> item) {
    final route = item['route'] as String?;
    
    if (route == null) {
      // Show "Coming soon" message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tính năng đang phát triển'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    if (route == 'logout') {
      // Show logout confirmation dialog
      _showLogoutDialog(context);
      return;
    }
    
    // Navigate to route
    context.push(route);
  }
  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                await authViewModel.logout();
                // Navigate to home after logout
                if (context.mounted) {
                  context.go('/home');
                }
              },
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}