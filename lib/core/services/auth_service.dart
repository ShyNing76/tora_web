import 'package:dio/dio.dart';
import 'package:tora/core/constants/app_constants.dart';
import 'api_service.dart';
import '../../models/user.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Đăng ký
  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String dateOfBirth,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.authRegister,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'dateOfBirth': dateOfBirth,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final userData = responseData?['data'];
        
        print('📥 Signup Response: $responseData');
        print('👤 User Data: $userData');
        
        return {
          'success': true,
          'data': responseData,
          'user': userData != null ? User.fromJson(userData) : null,
          'token': userData?['accessToken'],
          'refreshToken': userData?['refreshToken'],
          'expiresAt': userData?['expiresAt'],
          'message': 'Đăng ký thành công'
        };
      } else {
        return {
          'success': false,
          'message': 'Đăng ký thất bại'
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: $e'
      };
    }
  }
  
  // Đăng nhập
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.authLogin,
        data: {
          'email': email,
          'password': password,
          'rememberMe': true,
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        final userData = responseData?['data'];
        
        print('📥 Login Response: $responseData');
        print('👤 User Data: $userData');
        
        return {
          'success': true,
          'data': responseData,
          'user': userData != null ? User.fromJson(userData) : null,
          'token': userData?['accessToken'],
          'refreshToken': userData?['refreshToken'],
          'expiresAt': userData?['expiresAt'],
          'message': 'Đăng nhập thành công'
        };
      } else {
        return {
          'success': false,
          'message': 'Đăng nhập thất bại'
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: $e'
      };
    }
  }
  
  // Đăng xuất
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.authLogout,
      );

      print('📥 Logout Response: ${response.data}');
      
      // Clear authentication data và cookies
      await _apiService.clearAuthData();
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Đăng xuất thành công'
        };
      } else {
        return {
          'success': false,
          'message': 'Đăng xuất thất bại'
        };
      }
    } on DioException catch (e) {
      // Ngay cả khi logout API fail, vẫn clear local data
      await _apiService.clearAuthData();
      return _handleDioError(e);
    } catch (e) {
      // Ngay cả khi có lỗi, vẫn clear local data
      await _apiService.clearAuthData();
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: $e'
      };
    }
  }
  
  // Kiểm tra trạng thái đăng nhập
  Future<bool> isAuthenticated() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(AppConstants.authMe);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Lấy thông tin user hiện tại
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(AppConstants.authMe);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(response.data?['user']),
          'message': 'Lấy thông tin thành công'
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể lấy thông tin user'
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: $e'
      };
    }
  }
  
  // Refresh token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.authRefresh,
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': response.data?['token'],
          'message': 'Refresh token thành công'
        };
      } else {
        return {
          'success': false,
          'message': 'Refresh token thất bại'
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Có lỗi xảy ra: $e'
      };
    }
  }
  
  // Xử lý lỗi Dio
  Map<String, dynamic> _handleDioError(DioException error) {
    String message = 'Có lỗi xảy ra';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Kết nối timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Timeout khi gửi dữ liệu';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Timeout khi nhận dữ liệu';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        switch (statusCode) {
          case 400:
            message = responseData?['message'] ?? 'Dữ liệu không hợp lệ';
            break;
          case 401:
            message = 'Lỗi xác thực';
            break;
          case 403:
            message = 'Bị cấm truy cập';
            break;
          case 404:
            message = 'Không tìm thấy';
            break;
          case 409:
            message = responseData?['message'] ?? 'Dữ liệu đã tồn tại';
            break;
          case 422:
            message = responseData?['message'] ?? 'Dữ liệu không hợp lệ';
            break;
          case 500:
            message = 'Lỗi server';
            break;
          default:
            message = responseData?['message'] ?? 'Có lỗi xảy ra';
        }
        break;
      case DioExceptionType.connectionError:
        message = 'Không có kết nối mạng';
        break;
      case DioExceptionType.cancel:
        message = 'Yêu cầu bị hủy';
        break;
      default:
        message = error.message ?? 'Có lỗi xảy ra';
    }
    
    return {
      'success': false,
      'message': message,
      'statusCode': error.response?.statusCode,
    };
  }

  // Refresh session/token
  Future<bool> refreshSession() async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(AppConstants.authRefresh);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Clear all authentication data
  Future<void> clearSession() async {
    await _apiService.clearAuthData();
  }
}