import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../core/constants/app_colors.dart';

class AppWrapper extends StatefulWidget {
  final Widget child;
  
  const AppWrapper({super.key, required this.child});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    await authViewModel.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Show loading while checking auth status
        if (authViewModel.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải...',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return widget.child;
      },
    );
  }
}