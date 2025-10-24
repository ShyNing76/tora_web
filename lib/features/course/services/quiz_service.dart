import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../models/quiz.dart';

class QuizService {
  final ApiService _apiService = ApiService();

  // Get quiz by lesson ID
  Future<Map<String, dynamic>> getQuizByLessonId(String lessonId) async {
    try {
      print('📚 Fetching quiz for lesson: $lessonId');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '/app/api/Quiz/lessons/$lessonId',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final bool isSuccess = responseData?['isSuccess'] ?? false;
        
        if (isSuccess) {
          final quizList = responseData?['data'] as List?;
          
          if (quizList != null && quizList.isNotEmpty) {
            final quizData = quizList[0] as Map<String, dynamic>;
            
            print('✅ Quiz loaded successfully:');
            print('  - Name: ${quizData['name']}');
            print('  - Questions: ${quizData['questions']?.length ?? 0}');
            print('  - Time: ${quizData['time']} minutes');
            print('  - Pass Percent: ${quizData['passPercent']}%');

            // Parse quiz data
            final quiz = _parseQuizFromApi(quizData);

            return {
              'success': true,
              'quiz': quiz,
              'message': responseData?['message'] ?? 'Quiz loaded successfully',
            };
          } else {
            print('⚠️ No quiz found for this lesson');
            return {
              'success': false,
              'message': 'Không có bài kiểm tra cho bài học này',
            };
          }
        } else {
          print('❌ API returned isSuccess: false');
          return {
            'success': false,
            'message': responseData?['message'] ?? 'Không thể tải bài kiểm tra',
          };
        }
      } else {
        print('❌ Failed to load quiz, status code: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Không thể tải bài kiểm tra',
        };
      }
    } on DioException catch (e) {
      print('❌ Dio error loading quiz: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    } catch (e) {
      print('❌ Error loading quiz: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi tải bài kiểm tra',
      };
    }
  }

  Quiz _parseQuizFromApi(Map<String, dynamic> data) {
    // Parse questions
    List<QuizQuestion> questions = [];
    if (data['questions'] != null) {
      final questionsData = data['questions'] as List;
      
      questions = questionsData.map((q) {
        final questionData = q as Map<String, dynamic>;
        
        // Parse answers
        List<QuizAnswer> answers = [];
        if (questionData['answers'] != null) {
          final answersData = questionData['answers'] as List;
          answers = answersData.map((a) {
            final answerData = a as Map<String, dynamic>;
            return QuizAnswer(
              id: answerData['id'] ?? '',
              text: answerData['name'] ?? '',
            );
          }).toList();
        }
        
        // Correct answer will be empty when loading quiz
        // It will be revealed after submission
        String correctAnswerId = '';

        // Parse question type from 'type' field in API
        QuestionType questionType = QuestionType.singleChoice;
        if (questionData['type'] != null) {
          questionType = QuestionType.fromString(questionData['type']);
        }

        return QuizQuestion(
          id: questionData['id'] ?? '',
          question: questionData['name'] ?? '',
          correctAnswerId: correctAnswerId,
          explanation: questionData['description'] ?? '', // Use description as explanation
          answers: answers,
          questionType: questionType,
        );
      }).toList();
    }

    return Quiz(
      id: data['id'] ?? '',
      title: data['name'] ?? 'Bài kiểm tra',
      description: data['description'] ?? 'Bài kiểm tra giúp bạn củng cố kiến thức.',
      timeLimit: data['time'] ?? 10,
      passingScore: data['passPercent'] ?? 70,
      questions: questions,
    );
  }

  // Take quiz (start quiz session)
  Future<Map<String, dynamic>> takeQuiz(String quizId) async {
    try {
      print('🎯 Starting quiz session: $quizId');
      
      final response = await _apiService.post<Map<String, dynamic>>(
        '/app/api/Quiz/$quizId/take',
        data: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Quiz session started successfully');
        return {
          'success': true,
          'message': 'Quiz session started',
        };
      } else {
        print('❌ Failed to start quiz session: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Không thể bắt đầu bài kiểm tra',
        };
      }
    } on DioException catch (e) {
      print('❌ Dio error starting quiz: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    } catch (e) {
      print('❌ Error starting quiz: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi bắt đầu bài kiểm tra',
      };
    }
  }

  // Submit quiz answers
  Future<Map<String, dynamic>> submitQuiz({
    required String quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      print('📤 Submitting quiz: $quizId');
      print('📝 Total answers: ${answers.length}');
      
      final payload = {
        'quizId': quizId,
        'answers': answers,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        '/app/api/Quiz/$quizId/submissions',
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        print('✅ Quiz submitted successfully');
        print('📊 Score: ${responseData?['score']}');
        print('✔️ Passed: ${responseData?['isPassed']}');

        return {
          'success': true,
          'data': responseData,
          'message': 'Quiz submitted successfully',
        };
      } else {
        print('❌ Failed to submit quiz: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Không thể nộp bài kiểm tra',
        };
      }
    } on DioException catch (e) {
      print('❌ Dio error submitting quiz: ${e.message}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    } catch (e) {
      print('❌ Error submitting quiz: $e');
      return {
        'success': false,
        'message': 'Có lỗi xảy ra khi nộp bài kiểm tra',
      };
    }
  }
}
