import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tora/core/services/notification_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/user.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class LoggedInHomeScreen extends StatelessWidget {
  const LoggedInHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            final user = authViewModel.user;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header with user info and logout
                  _buildHeader(context, user, authViewModel),

                  // Welcome section
                  _buildWelcomeSection(user),

                  // Quick actions
                  _buildQuickActions(context),

                  // Recommended courses
                  _buildRecommendedCourses(),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    User? user,
    AuthViewModel authViewModel,
  ) {
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
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
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
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào 👋',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        user?.displayName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Logout button
              IconButton(
                onPressed: () => _showLogoutDialog(context, authViewModel),
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(User? user) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào mừng trở lại, ${user?.displayName ?? 'User'}!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy tiếp tục hành trình học tập của bạn, hôm nay bạn muốn học gì?',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hành động nhanh',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.play_circle_fill,
                  title: 'Tiếp tục học',
                  subtitle: 'Bài học gần nhất',
                  color: AppColors.primaryColor,
                  onTap: () {
                    // Xử lý khi nhấn vào "Tiếp tục học"
                    context.go('/courses');
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.quiz,
                  title: 'Làm bài thi',
                  subtitle: 'Kiểm tra kiến thức',
                  color: Colors.orange,
                  onTap: () {
                    context.go('/exams');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.book,
                  title: 'Khóa học mới',
                  subtitle: 'Khám phá thêm',
                  color: Colors.green,
                  onTap: () {
                    context.go('/courses');
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.analytics,
                  title: 'Tiến độ',
                  subtitle: 'Xem báo cáo',
                  color: Colors.purple,
                  onTap: () {
                    context.go('/progress');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedCourses() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khóa học đề xuất',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildCourseCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(int index) {
    final courses = [
      {
        'title': 'Giải tích nâng cao',
        'duration': '12 tuần',
        'lessons': '24 bài',
        'color': Colors.blue,
      },
      {
        'title': 'Vật lý đại cương',
        'duration': '10 tuần',
        'lessons': '20 bài',
        'color': Colors.green,
      },
      {
        'title': 'Hóa học hữu cơ',
        'duration': '8 tuần',
        'lessons': '16 bài',
        'color': Colors.orange,
      },
    ];

    final course = courses[index];

    return Container(
      width: 160,
      margin: EdgeInsets.only(right: index < courses.length - 1 ? 15 : 0),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: (course['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.school,
              color: course['color'] as Color,
              size: 40,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            course['title'] as String,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            course['duration'] as String,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor),
          ),
          Text(
            course['lessons'] as String,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryColor),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authViewModel) {
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
                // Close confirmation dialog first
                Navigator.of(dialogContext).pop();

                // Show loading indicator with overlay
                final overlay = Overlay.of(context);
                final overlayEntry = OverlayEntry(
                  builder: (context) => Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                );
                overlay.insert(overlayEntry);

                try {
                  // Call logout API
                  final success = await authViewModel.logout();

                  // Remove loading overlay
                  overlayEntry.remove();

                  // Show result message
                  if (context.mounted) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   // SnackBar(
                    //   //   content: Text(
                    //   //     success
                    //   //       ? 'Đăng xuất thành công'
                    //   //       : (authViewModel.errorMessage ?? 'Đăng xuất thất bại')
                    //   //   ),
                    //   //   backgroundColor: success ? Colors.green : Colors.orange,
                    //   //   duration: const Duration(seconds: 2),
                    //   // ),

                    // );
                    NotificationService.showNotification(
                      context,
                      message: success
                          ? 'Đăng xuất thành công!'
                          : (authViewModel.errorMessage ?? 'Đăng xuất thất bại'),
                      type: NotificationType.success,
                    );
                  }
                } catch (e) {
                  // Remove loading overlay in case of error
                  overlayEntry.remove();

                  if (context.mounted) {
                    NotificationService.showNotification(
                      context,
                      message: 'Có lỗi xảy ra khi đăng xuất',
                      type: NotificationType.error,
                    );
                  }
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
