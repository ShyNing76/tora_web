import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';

class WebViewScreen extends StatelessWidget {
  final String url;
  final String? title;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title,
  });

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tự động mở URL khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchUrl().then((_) {
        // Quay lại màn hình trước sau khi mở browser
        Navigator.of(context).pop();
      }).catchError((error) {
        // Hiển thị lỗi nếu không mở được
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở trang web: $error'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Đang mở trang web...',
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
}