import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../models/course.dart';

class CourseService {
  final ApiService _apiService = ApiService();
  
  // Get all courses with optional filters
  Future<Map<String, dynamic>> getCourses({
    int page = 1,
    int pageSize = 10,
    String? searchQuery,
    String? type,
    String? level,
  }) async {
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {
        'page': page,
        'pageSize': pageSize,
      };
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      
      if (type != null) {
        queryParams['type'] = type;
      }
      
      if (level != null) {
        queryParams['level'] = level;
      }
      
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.getCourses,
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        final List<dynamic> coursesJson = responseData?['items'] ?? [];
        
        print('📥 Get Courses Response: Found ${coursesJson.length} courses');
        
        // Parse courses
        List<Course> courses = coursesJson
            .map((json) => Course.fromJson(json as Map<String, dynamic>))
            .toList();
        
        return {
          'success': true,
          'courses': courses,
          'metadata': responseData?['metadata'],
          'message': responseData?['message'] ?? 'Lấy danh sách khóa học thành công',
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể lấy danh sách khóa học',
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      print('❌ Get courses error: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi lấy danh sách khóa học: $e',
      };
    }
  }
  
  // Get course detail by ID
  Future<Map<String, dynamic>> getCourseById(String courseId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.getCourses}/$courseId',
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        final courseJson = responseData?['data'];
        
        if (courseJson != null) {
          Course course = Course.fromJson(courseJson as Map<String, dynamic>);
          
          return {
            'success': true,
            'course': course,
            'message': 'Lấy thông tin khóa học thành công',
          };
        } else {
          return {
            'success': false,
            'message': 'Không tìm thấy thông tin khóa học',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Không thể lấy thông tin khóa học',
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      print('❌ Get course detail error: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi lấy thông tin khóa học: $e',
      };
    }
  }
  
  // Check course enrollment and progress
  Future<Map<String, dynamic>> getCourseProgress(String courseId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/learning/api/CourseEnroll/courses/$courseId/progress',
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        final bool isEnrolled = responseData?['isSuccess'] ?? false;
        final progressData = responseData?['data'];
        
        print('📥 Course Progress Response:');
        print('  - isSuccess: $isEnrolled');
        print('  - completedLessons: ${progressData?['completedLessons']}/${progressData?['totalLessons']}');
        print('  - completedChapters: ${progressData?['completedChapters']}/${progressData?['totalChapters']}');
        print('  - percent: ${progressData?['percent']}%');
        
        return {
          'success': true,
          'isEnrolled': isEnrolled,
          'progressData': progressData,
          'message': responseData?['message'] ?? 'Lấy thông tin tiến độ thành công',
        };
      } else {
        return {
          'success': true,
          'isEnrolled': false,
          'message': 'Chưa đăng ký khóa học',
        };
      }
    } on DioException catch (e) {
      // If 404 or not enrolled, treat as not enrolled
      if (e.response?.statusCode == 404) {
        print('📥 Course Progress: 404 - Not enrolled');
        return {
          'success': true,
          'isEnrolled': false,
          'message': 'Chưa đăng ký khóa học',
        };
      }
      return _handleDioError(e);
    } catch (e) {
      print('❌ Get course progress error: $e');
      return {
        'success': false,
        'isEnrolled': false,
        'message': 'Có lỗi xảy ra khi lấy thông tin tiến độ: $e',
      };
    }
  }
  
  Map<String, dynamic> _handleDioError(DioException e) {
    String errorMessage = 'Có lỗi xảy ra';
    
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      print('❌ Course API Error - Status: $statusCode');
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
            errorMessage = 'Không tìm thấy khóa học';
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
