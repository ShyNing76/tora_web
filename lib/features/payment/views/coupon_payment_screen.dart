import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../services/payment_service.dart';

class CouponPaymentScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  const CouponPaymentScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CouponPaymentScreen> createState() => _CouponPaymentScreenState();
}

class _CouponPaymentScreenState extends State<CouponPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _couponController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }
  
  Future<void> _applyCoupon() async {
    final couponCode = _couponController.text.trim();
    
    if (couponCode.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập mã coupon';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final result = await _paymentService.createPayment(
      orderType: 'BuyCourse',
      referenceId: widget.courseId,
      couponCode: couponCode,
    );
    
    if (result['success'] == true && mounted) {
      final paymentData = result['paymentData'];
      final status = paymentData['status'];
      
      print('✅ Coupon payment created with status: $status');
      
      // Check if payment is immediately completed (100% discount)
      if (status == 'Paid' || status == 'Completed') {
        _showSuccessDialog();
      } else {
        // If not immediately completed, check status
        final orderId = paymentData['orderId'];
        if (orderId != null) {
          await _checkPaymentStatus(orderId);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Không thể kiểm tra trạng thái thanh toán';
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Mã coupon không hợp lệ';
      });
    }
  }
  
  Future<void> _checkPaymentStatus(String orderId) async {
    final result = await _paymentService.checkPaymentStatus(orderId);
    
    if (result['success'] == true && mounted) {
      final status = result['status'];
      
      if (status == 'Paid' || status == 'Completed') {
        _showSuccessDialog();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Thanh toán chưa hoàn tất. Trạng thái: $status';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Không thể kiểm tra trạng thái thanh toán';
      });
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.successColor, size: 28),
              SizedBox(width: 8),
              Text('Đăng ký thành công'),
            ],
          ),
          content: const Text(
            'Chúc mừng! Bạn đã đăng ký khóa học thành công bằng mã coupon. Bây giờ bạn có thể bắt đầu học.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(true); // Return to course detail with success
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Bắt đầu học'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Thanh toán bằng Coupon',
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Info
              Container(
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: AppColors.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Khóa học',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.courseName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Coupon Code Section
              const Text(
                'Nhập mã Coupon',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nhập mã coupon của bạn để được giảm giá hoặc miễn phí khóa học',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Coupon Input
              TextField(
                controller: _couponController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: FREE100',
                  prefixIcon: const Icon(Icons.local_offer, color: AppColors.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                onChanged: (value) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),
              
              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.errorColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Áp dụng mã',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Lưu ý',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Mỗi mã coupon chỉ được sử dụng một lần\n'
                      '• Mã coupon có thể hết hạn hoặc đã đạt giới hạn sử dụng\n'
                      '• Vui lòng nhập chính xác mã coupon',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
