import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class StatsService {
  final ApiService _apiService = ApiService();

  // Get user stats
  Future<Map<String, dynamic>> getMyStats() async {
    try {
      print('📊 Fetching user stats...');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/learning/api/Stats/me',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final bool isSuccess = responseData?['isSuccess'] ?? false;
        
        if (isSuccess) {
          final statsData = responseData?['data'];
          
          print('✅ Stats loaded successfully:');
          print('  - Total Courses Learned: ${statsData?['totalCoursesLearned']}');
          print('  - Total Enrolled Courses: ${statsData?['totalEnrolledCourses']}');
          print('  - Total Quizzes Taken: ${statsData?['totalQuizzesTaken']}');
          print('  - Total Lessons Learned: ${statsData?['totalLessonsLearned']}');
          print('  - Current Streak: ${statsData?['currentStreak']}');
          print('  - Best Streak: ${statsData?['bestStreak']}');
          
          return {
            'success': true,
            'data': statsData,
            'message': responseData?['message'] ?? 'Stats loaded successfully',
          };
        } else {
          return {
            'success': false,
            'message': responseData?['message'] ?? 'Không thể tải thống kê',
          };
        }
      } else {
        print('❌ Failed to load stats, status code: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Không thể tải thống kê',
        };
      }
    } on DioException catch (e) {
      print('❌ Dio error loading stats: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    } catch (e) {
      print('❌ Error loading stats: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi tải thống kê',
      };
    }
  }

  // Get weekly lessons progress (last 7 days)
  Future<Map<String, dynamic>> getWeeklyLessonsProgress() async {
    try {
      print('📅 Fetching weekly lessons progress...');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/learning/api/Stats/me/lessons/weekly',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final bool isSuccess = responseData?['isSuccess'] ?? false;
        
        if (isSuccess) {
          final weeklyData = responseData?['data'] as Map<String, dynamic>?;
          
          print('✅ Weekly progress loaded successfully:');
          weeklyData?.forEach((date, lessons) {
            print('  - $date: $lessons lessons');
          });
          
          return {
            'success': true,
            'data': weeklyData,
            'message': responseData?['message'] ?? 'Weekly progress loaded',
          };
        } else {
          return {
            'success': false,
            'message': responseData?['message'] ?? 'Không thể tải tiến độ tuần',
          };
        }
      } else {
        print('❌ Failed to load weekly progress, status code: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Không thể tải tiến độ tuần',
        };
      }
    } on DioException catch (e) {
      print('❌ Dio error loading weekly progress: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    } catch (e) {
      print('❌ Error loading weekly progress: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi tải tiến độ tuần',
      };
    }
  }
}
