import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class AiChatService {
  final ApiService _apiService = ApiService();
  late Dio _dio;

  AiChatService() {
    // Get the configured Dio instance from ApiService (with cookies)
    _dio = _apiService.dio;
  }

  /// Stream chat messages from AI
  /// Returns a stream of message chunks that should be concatenated
  Stream<String> streamChat({
    required String lessonId,
    required String question,
  }) async* {
    try {
      print('🤖 Starting AI chat stream for lesson: $lessonId');
      print('❓ Question: $question');

      final response = await _dio.post<ResponseBody>(
        '/learning/api/AiChat/stream',
        data: {
          'lessonId': lessonId,
          'question': question,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': '*/*',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data == null) {
        print('❌ No response data');
        yield 'Xin lỗi, không thể kết nối với AI. Vui lòng thử lại.';
        return;
      }

      final stream = response.data!.stream;
      String buffer = '';
      List<int> byteBuffer = [];

      await for (final chunk in stream) {
        // Accumulate bytes instead of decoding immediately
        byteBuffer.addAll(chunk);
        
        // Try to decode accumulated bytes
        String chunkString;
        try {
          chunkString = utf8.decode(byteBuffer);
          byteBuffer.clear(); // Clear buffer if decode successful
        } catch (e) {
          // If decode fails, it means we have incomplete UTF-8 sequence
          // Keep bytes in buffer and wait for more data
          continue;
        }
        
        buffer += chunkString;

        // Process complete lines
        final lines = buffer.split('\n');
        
        // Keep the last incomplete line in buffer
        buffer = lines.last;

        // Process complete lines (all except the last one)
        for (int i = 0; i < lines.length - 1; i++) {
          String line = lines[i].trim();
          
          if (line.isEmpty || line == 'data: [DONE]') {
            continue;
          }

          // Remove "data: " prefix if present
          if (line.startsWith('data: ')) {
            line = line.substring(6);
          }

          try {
            final jsonData = jsonDecode(line);
            
            // Only process "item" type messages with content
            if (jsonData['type'] == 'item' && jsonData['content'] != null) {
              String content = jsonData['content'];
              
              // Check if this is the final wrapped response
              if (content.startsWith('{') && content.contains('"output"')) {
                try {
                  final outputJson = jsonDecode(content);
                  if (outputJson['output'] != null) {
                    // This is the final complete message, skip it
                    // We already have all chunks
                    continue;
                  }
                } catch (_) {
                  // Not a JSON, treat as normal content
                }
              }
              
              yield content;
              print('📝 AI chunk: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
            }
          } catch (e) {
            print('⚠️ Failed to parse line: $line');
            print('Error: $e');
          }
        }
      }

      print('✅ AI chat stream completed');
    } on DioException catch (e) {
      print('❌ AI chat stream error: ${e.message}');
      
      String errorMessage = 'Xin lỗi, đã xảy ra lỗi khi kết nối với AI.';
      
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 401:
            errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
            break;
          case 403:
            errorMessage = 'Bạn không có quyền truy cập tính năng này.';
            break;
          case 404:
            errorMessage = 'Không tìm thấy bài học này.';
            break;
          case 500:
            errorMessage = 'Lỗi máy chủ. Vui lòng thử lại sau.';
            break;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Kết nối bị timeout. Vui lòng kiểm tra mạng và thử lại.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Không có kết nối internet. Vui lòng kiểm tra kết nối.';
      }
      
      yield errorMessage;
    } catch (e) {
      print('❌ Unexpected error in AI chat stream: $e');
      yield 'Xin lỗi, đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';
    }
  }
}
