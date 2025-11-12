import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();
  
  // Create payment order
  Future<Map<String, dynamic>> createPayment({
    required String orderType,
    required String referenceId,
    String? couponCode,
  }) async {
    try {
      final data = {
        'orderType': orderType,
        'referenceId': referenceId,
      };
      
      if (couponCode != null && couponCode.isNotEmpty) {
        data['couponCode'] = couponCode;
      }
      
      final response = await _apiService.post<Map<String, dynamic>>(
        '/payment/api/Payment/create-payment',
        data: data,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final bool isSuccess = responseData?['isSuccess'] ?? false;
        
        if (isSuccess) {
          final paymentData = responseData?['data'];
          
          print('📥 Payment Created Successfully:');
          print('  - Order ID: ${paymentData?['orderId']}');
          print('  - Amount: ${paymentData?['amount']} ${paymentData?['currency']}');
          print('  - Status: ${paymentData?['status']}');
          print('  - Code: ${paymentData?['code']}');
          print('  - QR URL: ${paymentData?['qrCodeUrl']}');
          
          return {
            'success': true,
            'paymentData': paymentData,
            'message': responseData?['message'] ?? 'Tạo thanh toán thành công',
          };
        } else {
          return {
            'success': false,
            'message': responseData?['message'] ?? 'Không thể tạo thanh toán',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Không thể tạo thanh toán',
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      print('❌ Create payment error: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi tạo thanh toán: $e',
      };
    }
  }
  
  // Check payment status
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/payment/api/Payment/orders/$orderId',
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        final paymentStatus = responseData?['data']?['status'];
        final paidAt = responseData?['data']?['paidAt'];
        
        print('📥 Payment Status Check:');
        print('  - Status: $paymentStatus');
        print('  - Paid At: $paidAt');
        print('  - Order ID: $orderId');
        
        return {
          'success': true,
          'status': paymentStatus,
          'data': responseData?['data'],
        };
      } else {
        print('❌ Payment status check failed with status code: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Không thể kiểm tra trạng thái thanh toán',
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      print('❌ Check payment status error: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi kiểm tra trạng thái: $e',
      };
    }
  }
  
  Map<String, dynamic> _handleDioError(DioException e) {
    String errorMessage = 'Có lỗi xảy ra';
    
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      print('❌ Payment API Error - Status: $statusCode');
      print('Response: $responseData');
      
      if (responseData is Map && responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      } else {
        switch (statusCode) {
          case 400:
            errorMessage = 'Yêu cầu không hợp lệ';
            break;
          case 401:
            errorMessage = 'Phiên đăng nhập đã hết hạn';
            break;
          case 403:
            errorMessage = 'Không có quyền truy cập';
            break;
          case 404:
            errorMessage = 'Không tìm thấy thông tin thanh toán';
            break;
          case 500:
            errorMessage = 'Lỗi máy chủ';
            break;
          default:
            errorMessage = 'Có lỗi xảy ra';
        }
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
               e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Kết nối bị timeout';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'Không có kết nối internet';
    }
    
    return {
      'success': false,
      'message': errorMessage,
    };
  }
}
