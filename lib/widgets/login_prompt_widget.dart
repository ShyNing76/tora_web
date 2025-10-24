import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class LoginPromptWidget extends StatelessWidget {
  final String message;
  final String? description;
  final bool isOverlay;
  final VoidCallback? onClose;
  
  const LoginPromptWidget({
    super.key,
    this.message = 'Bạn phải đăng nhập để thực hiện chức năng này',
    this.description,
    this.isOverlay = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(24),
      margin: isOverlay ? const EdgeInsets.all(20) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isOverlay ? BorderRadius.circular(16) : null,
        boxShadow: isOverlay ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button for overlay
          if (isOverlay && onClose != null)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
            ),
          
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 48,
              color: AppColors.primaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Title
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (onClose != null) onClose!();
                    context.push('/signup');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Đăng ký',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (onClose != null) onClose!();
                    context.push('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (isOverlay) {
      return Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: content,
        ),
      );
    }

    return content;
  }
}

// Overlay version for full screen blocking
class LoginPromptOverlay extends StatelessWidget {
  final String message;
  final String? description;
  
  const LoginPromptOverlay({
    super.key,
    this.message = 'Bạn phải đăng nhập để thực hiện chức năng này',
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LoginPromptWidget(
        message: message,
        description: description,
        isOverlay: true,
        onClose: () {
          // For overlay, we might want to navigate back or do nothing
          // Let the parent handle the close action
        },
      ),
    );
  }
}