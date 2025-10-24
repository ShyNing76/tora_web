import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class LessonService {
  final ApiService _apiService = ApiService();

  // Get lesson content by lesson ID
  Future<Map<String, dynamic>> getLessonContent(String lessonId) async {
    try {
      print('📖 Fetching lesson content for lesson: $lessonId');

      final response = await _apiService.get<Map<String, dynamic>>(
        '/app/api/LessonContent/by-lesson/$lessonId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final bool isSuccess = responseData?['isSuccess'] ?? false;

        if (isSuccess) {
          final contentData = responseData?['data'];

          print('✅ Lesson content loaded successfully');
          print('   - Video URL: ${contentData?['videoUrl']}');
          print('   - Has content: ${contentData?['content'] != null}');

          return {
            'success': true,
            'data': contentData,
            'message': responseData?['message'] ?? 'Content loaded',
          };
        } else {
          return {
            'success': false,
            'message': responseData?['message'] ?? 'Không thể tải nội dung',
          };
        }
      } else {
        print(
          '❌ Failed to load lesson content, status code: ${response.statusCode}',
        );
        return {'success': false, 'message': 'Không thể tải nội dung bài học'};
      }
    } on DioException catch (e) {
      print('❌ Dio error loading lesson content: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    } catch (e) {
      print('❌ Error loading lesson content: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra khi tải nội dung'};
    }
  }

  // Get lesson summary by lesson ID
  Future<Map<String, dynamic>> getLessonSummary(String lessonId) async {
    try {
      print('📝 Fetching lesson summary for lesson: $lessonId');

      final response = await _apiService.get<Map<String, dynamic>>(
        '/app/api/LessonSummary/$lessonId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final bool isSuccess = responseData?['isSuccess'] ?? false;

        if (isSuccess) {
          final summaryData = responseData?['data'];

          print('✅ Lesson summary loaded successfully');
          print('   - Has content: ${summaryData?['content'] != null}');

          return {
            'success': true,
            'data': summaryData,
            'message': responseData?['message'] ?? 'Summary loaded',
          };
        } else {
          return {
            'success': false,
            'message': responseData?['message'] ?? 'Không thể tải tóm tắt',
          };
        }
      } else {
        print(
          '❌ Failed to load lesson summary, status code: ${response.statusCode}',
        );
        return {'success': false, 'message': 'Không thể tải tóm tắt bài học'};
      }
    } on DioException catch (e) {
      print('❌ Dio error loading lesson summary: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    } catch (e) {
      print('❌ Error loading lesson summary: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra khi tải tóm tắt'};
    }
  }

  // Get lesson flashcards by lesson ID
  Future<Map<String, dynamic>> getLessonFlashcards(String lessonId) async {
    try {
      print('🃏 Fetching lesson flashcards for lesson: $lessonId');

      final response = await _apiService.get<Map<String, dynamic>>(
        '/app/api/LessonFlashcard/$lessonId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final bool isSuccess = responseData?['isSuccess'] ?? false;

        if (isSuccess) {
          final flashcardData = responseData?['data'];

          print('✅ Lesson flashcard loaded successfully');
          print('   - Question: ${flashcardData?['question']}');
          print('   - Ordering: ${flashcardData?['ordering']}');

          return {
            'success': true,
            'data': flashcardData,
            'message': responseData?['message'] ?? 'Flashcard loaded',
          };
        } else {
          return {
            'success': false,
            'message': responseData?['message'] ?? 'Không thể tải flashcard',
          };
        }
      } else {
        print(
          '❌ Failed to load lesson flashcard, status code: ${response.statusCode}',
        );
        return {'success': false, 'message': 'Không thể tải flashcard'};
      }
    } on DioException catch (e) {
      print('❌ Dio error loading lesson flashcard: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    } catch (e) {
      print('❌ Error loading lesson flashcard: $e');
      return {'success': false, 'message': 'Có lỗi xảy ra khi tải flashcard'};
    }
  }

  // Mark lesson as complete
  Future<Map<String, dynamic>> completeLessonAudit({
    required String lessonId,
    required String courseId,
    required String chapterId,
    required String materialId,
    required String activeType,
    String completionReason = 'Completed viewing content',
  }) async {
    try {
      print('✅ Marking lesson as complete: $lessonId');
      print('   - Course ID: $courseId');
      print('   - Chapter ID: $chapterId');
      print('   - Material ID: $materialId');
      print('   - Active Type: $activeType');

      final body = {
        'courseId': courseId,
        'chapterId': chapterId,
        'materialId': materialId,
        'activeType': activeType,
        'completionReason': completionReason,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        '/learning/api/LessonAudit/$lessonId/complete',
        data: body,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        print('✅ Lesson marked as complete successfully');

        return {
          'success': true,
          'data': responseData?['data'],
          'message': responseData?['message'] ?? 'Lesson completed',
        };
      } else {
        print(
          '❌ Failed to mark lesson complete, status code: ${response.statusCode}',
        );
        return {
          'success': false,
          'message': 'Không thể đánh dấu hoàn thành bài học',
        };
      }
    } on DioException catch (e) {
      print('❌ Dio error marking lesson complete: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    } catch (e) {
      print('❌ Error marking lesson complete: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi đánh dấu hoàn thành',
      };
    }
  }
}
