import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../services/payment_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  final String courseId;
  final String courseName;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  
  bool _isLoading = true;
  String? _errorMessage;
  
  // Payment data
  String? _orderId;
  String? _qrCodeUrl;
  double? _amount;
  String? _currency;
  String? _code;
  String? _status;
  DateTime? _expiresAt;
  
  // Bank transfer data
  String? _bankId;
  String? _accountNumber;
  String? _accountName;
  String? _addInfo;
  
  Timer? _countdownTimer;
  Timer? _statusCheckTimer;
  Duration _remainingTime = const Duration();
  
  @override
  void initState() {
    super.initState();
    _createPayment();
  }
  
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _createPayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final result = await _paymentService.createPayment(
      orderType: 'BuyCourse',
      referenceId: widget.courseId,
    );
    
    if (result['success'] == true && mounted) {
      final paymentData = result['paymentData'];
      final bankTransfer = paymentData['bankTransfer'];
      
      setState(() {
        _orderId = paymentData['orderId'];
        _qrCodeUrl = bankTransfer['qrImageUrl'];
        _amount = paymentData['amount'];
        _currency = paymentData['currency'];
        _code = paymentData['code'];
        _status = paymentData['status'];
        
        if (paymentData['expiresAt'] != null) {
          _expiresAt = DateTime.parse(paymentData['expiresAt']);
          _startCountdown();
        }
        
        _bankId = bankTransfer['bankId'];
        _accountNumber = bankTransfer['accountNumber'];
        _accountName = bankTransfer['accountName'];
        _addInfo = bankTransfer['addInfo'];
        
        _isLoading = false;
      });
      
      // Start checking payment status every 5 seconds
      _startStatusCheck();
      
      print('✅ Payment created successfully, starting status check every 5 seconds...');
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Không thể tạo thanh toán';
      });
    }
  }
  
  void _startCountdown() {
    if (_expiresAt == null) return;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = _expiresAt!.difference(now);
      
      if (difference.isNegative) {
        timer.cancel();
        setState(() {
          _remainingTime = Duration.zero;
          _status = 'Expired';
        });
      } else {
        setState(() {
          _remainingTime = difference;
        });
      }
    });
  }
  
  void _startStatusCheck() {
    if (_orderId == null) return;
    
    print('🚀 Starting payment status check for order: $_orderId');
    
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      print('⏰ Timer tick - checking payment status...');
      final result = await _paymentService.checkPaymentStatus(_orderId!);
      
      print('📦 Result from checkPaymentStatus: $result');
      
      if (result['success'] == true) {
        final status = result['status'];
        
        print('🔍 Payment status received: $status');
        
        // Check for both 'Paid' and 'Completed' status
        if (status == 'Paid' || status == 'Completed') {
          print('✅ Payment successful! Showing success dialog...');
          timer.cancel();
          _countdownTimer?.cancel(); // Stop countdown timer too
          _showPaymentSuccessDialog();
        } else if (status == 'Failed' || status == 'Cancelled' || status == 'Expired') {
          print('❌ Payment failed with status: $status');
          timer.cancel();
          _countdownTimer?.cancel();
          setState(() {
            _status = status;
          });
          _showPaymentFailedDialog(status);
        } else {
          print('⏳ Payment still pending with status: $status');
        }
      } else {
        print('⚠️ Failed to check payment status: ${result['message']}');
      }
    });
  }
  
  void _showPaymentSuccessDialog() {
    print('🎉 _showPaymentSuccessDialog called!');
    print('🔍 mounted: $mounted');
    print('🔍 context: $context');
    
    if (!mounted) {
      print('❌ Widget not mounted, cannot show dialog');
      return;
    }
    
    // Use WidgetsBinding to ensure dialog shows after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎬 Showing dialog now...');
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          print('✅ Dialog builder called');
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.successColor, size: 28),
                SizedBox(width: 4),
                Text('Thanh toán thành công'),
              ],
            ),
            content: const Text(
              'Chúc mừng! Bạn đã đăng ký khóa học thành công. Bây giờ bạn có thể bắt đầu học.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  print('👆 User clicked "Bắt đầu học"');
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
      ).then((value) {
        print('📤 Dialog dismissed with value: $value');
      });
    });
  }
  
  void _showPaymentFailedDialog(String status) {
    if (!mounted) return;
    
    String message;
    switch (status) {
      case 'Failed':
        message = 'Thanh toán thất bại. Vui lòng thử lại.';
        break;
      case 'Cancelled':
        message = 'Thanh toán đã bị hủy.';
        break;
      case 'Expired':
        message = 'Thanh toán đã hết hạn. Vui lòng tạo thanh toán mới.';
        break;
      default:
        message = 'Có lỗi xảy ra với thanh toán.';
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.errorColor, size: 32),
              SizedBox(width: 12),
              Text('Thanh toán không thành công'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(false); // Return to course detail
              },
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _createPayment(); // Retry payment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _downloadQRCode() async {
    if (_qrCodeUrl == null) return;
    
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang tải QR code...')),
      );
      
      final response = await http.get(Uri.parse(_qrCodeUrl!));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/qr_code_${_code}.png');
      
      await file.writeAsBytes(response.bodyBytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu QR code vào ${file.path}'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải QR code'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }
  
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
          'Thanh toán chuyển khoản',
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildPaymentView(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Countdown Timer
          if (_expiresAt != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _remainingTime.inSeconds > 0
                  ? AppColors.warningColor.withOpacity(0.1)
                  : AppColors.errorColor.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    color: _remainingTime.inSeconds > 0
                        ? AppColors.warningColor
                        : AppColors.errorColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Thời hạn để thanh toán chuyển khoản',
                    style: TextStyle(
                      fontSize: 14,
                      color: _remainingTime.inSeconds > 0
                          ? AppColors.textPrimaryColor
                          : AppColors.errorColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _remainingTime.inSeconds > 0
                          ? AppColors.errorColor
                          : AppColors.textSecondaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(_remainingTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Payment Method
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cách thanh toán',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Truy cập Internet Banking hoặc ứng dụng của 42 ngân hàng, chọn chuyển khoản nhanh 24/7',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                // Bank icons (simplified)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBankIcon(Icons.account_balance, 'VCB'),
                    _buildBankIcon(Icons.account_balance, 'TCB'),
                    _buildBankIcon(Icons.account_balance, 'VPB'),
                    _buildBankIcon(Icons.account_balance, 'MB'),
                    _buildBankIcon(Icons.account_balance, 'ACB'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '+36',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bank Account Information
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                const Text(
                  'Nhập thông tin tài khoản được cung cấp',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Bank name
                _buildInfoRow(
                  'Ngân hàng thụ hưởng',
                  _getBankName(_bankId ?? ''),
                  Icons.account_balance,
                ),
                
                const Divider(height: 24),
                
                // Account number
                _buildInfoRow(
                  'Số tài khoản',
                  _accountNumber ?? '',
                  Icons.credit_card,
                  copyable: true,
                ),
                
                const Divider(height: 24),
                
                // Amount
                _buildInfoRow(
                  'Số tiền',
                  '${_formatAmount(_amount ?? 0)}đ',
                  Icons.payments,
                  copyable: true,
                  copyValue: _amount?.toString() ?? '',
                ),
                
                const Divider(height: 24),
                
                // Account name
                _buildInfoRow(
                  'Họ và tên',
                  _accountName ?? '',
                  Icons.person,
                ),
                
                const Divider(height: 24),
                
                // Transfer note
                _buildInfoRow(
                  'Nội dung chuyển khoản',
                  _addInfo ?? '(Không bắt buộc)',
                  Icons.note,
                  copyable: true,
                  copyValue: _addInfo,
                ),
                
                const SizedBox(height: 16),
                
                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.errorColor,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Bạn có thể thực hiện chuyển khoản nhanh hơn bằng cách quét hoặc tải mã QR lên ứng dụng ngân hàng.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // QR Code Image
                      if (_qrCodeUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _qrCodeUrl!,
                            height: 250,
                            width: 250,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 250,
                                width: 250,
                                color: AppColors.borderColor,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                width: 250,
                                color: AppColors.borderColor,
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Download QR button
                      OutlinedButton.icon(
                        onPressed: _downloadQRCode,
                        icon: const Icon(Icons.download),
                        label: const Text('Tải QR'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          side: const BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notice
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Trang thái đơn hàng sẽ được cập nhật ngay lập tức sau khi chuyển khoản thanh công.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Complete button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  print('👆 User clicked "Hoàn tất thanh toán" button');
                  
                  // Check status one more time manually
                  if (_orderId != null) {
                    print('📞 Calling checkPaymentStatus for orderId: $_orderId');
                    final result = await _paymentService.checkPaymentStatus(_orderId!);
                    
                    print('📦 Manual check result: $result');
                    
                    if (result['success'] == true) {
                      final status = result['status'];
                      print('🔍 Manual check - Payment status: $status');
                      
                      if (status == 'Paid' || status == 'Completed') {
                        print('💰 Status is Paid/Completed, stopping timers and showing dialog...');
                        _statusCheckTimer?.cancel();
                        _countdownTimer?.cancel();
                        _showPaymentSuccessDialog();
                      } else {
                        print('⏳ Status is not Paid/Completed yet: $status');
                        // Show current status to user
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Trạng thái hiện tại: $status'),
                            backgroundColor: AppColors.warningColor,
                          ),
                        );
                      }
                    } else {
                      print('❌ Manual check failed: ${result['message']}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: ${result['message']}'),
                          backgroundColor: AppColors.errorColor,
                        ),
                      );
                    }
                  } else {
                    print('❌ orderId is null!');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Hoàn tất thanh toán',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildBankIcon(IconData icon, String name) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primaryColor),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(
    String label,
    String value, 
    IconData icon, {
    bool copyable = false,
    String? copyValue,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
        if (copyable)
          IconButton(
            onPressed: () => _copyToClipboard(copyValue ?? value, label),
            icon: const Icon(Icons.content_copy, size: 20),
            color: AppColors.primaryColor,
          ),
      ],
    );
  }
  
  String _getBankName(String bankId) {
    final bankNames = {
      '970422': 'MB Bank',
      '970415': 'VietinBank',
      '970436': 'Vietcombank',
      '970418': 'BIDV',
      '970405': 'Agribank',
      '970407': 'Techcombank',
      '970432': 'VPBank',
      // Add more banks as needed
    };
    return bankNames[bankId] ?? 'VPBank';
  }
  
  String _formatAmount(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
