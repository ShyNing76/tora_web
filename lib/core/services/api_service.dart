import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  late CookieJar _cookieJar;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio();
    _setupCookies();
    _setupInterceptors();
  }

  void _setupCookies() async {
    try {
      // Tạo persistent cookie jar để lưu cookies
      final appDocDir = await getApplicationDocumentsDirectory();
      final cookiePath = "${appDocDir.path}/.cookies/";
      _cookieJar = PersistCookieJar(storage: FileStorage(cookiePath));

      // Add cookie manager to Dio
      _dio.interceptors.add(CookieManager(_cookieJar));

      // if (kDebugMode) {
      //   print('✅ Cookie manager initialized at: $cookiePath');
      // }
    } catch (e) {
      // Fallback to in-memory cookie jar
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar));

      // if (kDebugMode) {
      //   print('⚠️ Using in-memory cookie jar: $e');
      // }
    }
  }

  void _setupInterceptors() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = Duration(
      seconds: int.parse(AppConstants.apiTimeout),
    );
    _dio.options.receiveTimeout = Duration(
      seconds: int.parse(AppConstants.apiTimeout),
    );
    _dio.options.sendTimeout = Duration(
      seconds: int.parse(AppConstants.apiTimeout),
    );

    // Cookie-based authentication - không cần Authorization header
    _dio.options.extra['withCredentials'] = true;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Đảm bảo cookies được gửi kèm
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';

          if (kDebugMode) {
            print('🚀 REQUEST: ${options.method} ${options.uri}');
            print('📤 Headers: ${options.headers}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
            );
            print('📥 Data: ${response.data}');

            // Log cookies nếu có
            final cookies = response.headers['set-cookie'];
            if (cookies != null && cookies.isNotEmpty) {
              print('🍪 Cookies received: ${cookies.length} cookies');
            }
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('❌ ERROR: ${error.message}');
          }

          // Handle 401 - Token expired, try refresh
          if (error.response?.statusCode == 401) {
            // Nếu lỗi đến từ request refresh chính nó thì không thử refresh lại
            if (error.requestOptions.extra['refresh_call'] == true) {
              if (kDebugMode) {
                print('🔒 Refresh endpoint failed - logging out.');
              }
              await clearAuthData();
              return handler.next(error);
            }

            // Lấy số lần thử refresh đã thực hiện cho request này (mặc định 0)
            var attempts =
                (error.requestOptions.extra['refresh_attempts'] as int?) ?? 0;

            if (attempts >= 3) {
              if (kDebugMode) {
                print('🔒 Refresh failed $attempts lần. Logging out.');
              }
              await clearAuthData();
              return handler.next(error);
            }

            if (kDebugMode) {
              print(
                '🔄 Attempting to refresh token... (Attempt ${attempts + 1})',
              );
            }

            // Tăng counter cho request gốc để tránh loop vô hạn
            error.requestOptions.extra['refresh_attempts'] = attempts + 1;

            try {
              // Gọi refresh token endpoint — đánh dấu là refresh call để tránh recursion
              final refreshResponse = await _dio.post(
                AppConstants.authRefresh,
                options: Options(extra: {'refresh_call': true}),
              );

              if (refreshResponse.statusCode == 200) {
                // Reset counter trước khi retry
                error.requestOptions.extra.remove('refresh_attempts');

                final retryResponse = await _dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                );

                return handler.resolve(retryResponse);
              } else {
                if (kDebugMode) {
                  print(
                    '🔄 Refresh returned status ${refreshResponse.statusCode}',
                  );
                }
                if ((error.requestOptions.extra['refresh_attempts'] as int) >=
                    3) {
                  await clearAuthData();
                }
              }
            } catch (refreshError) {
              if (kDebugMode) {
                print('❌ Refresh error: $refreshError');
              }
              if ((error.requestOptions.extra['refresh_attempts'] as int) >=
                  3) {
                await clearAuthData();
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  // Clear authentication data và cookies
  Future<void> clearAuthData() async {
    try {
      // Xóa tất cả cookies
      _cookieJar.deleteAll();

      // if (kDebugMode) {
      //   print('🗑️ Cleared all authentication data and cookies');
      // }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing auth data: $e');
      }
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    return await _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    return await _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) async {
    return await _dio.delete<T>(path);
  }
}
