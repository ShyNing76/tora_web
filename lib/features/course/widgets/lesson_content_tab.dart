import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../models/chapter.dart';
import '../services/lesson_service.dart';

class LessonContentTab extends StatefulWidget {
  final Lesson lesson;
  final String courseId;

  const LessonContentTab({
    super.key,
    required this.lesson,
    required this.courseId,
  });

  @override
  State<LessonContentTab> createState() => _LessonContentTabState();
}

class _LessonContentTabState extends State<LessonContentTab> {
  final LessonService _lessonService = LessonService();
  
  YoutubePlayerController? _youtubeController;
  bool _hasValidVideo = false;
  bool _isLoading = true;
  String? _errorMessage;
  String? _videoUrl;
  String? _content;
  String? _materialId; // Store material ID from API response
  
  Timer? _completionTimer;
  bool _hasMarkedComplete = false;

  @override
  void initState() {
    super.initState();
    _loadLessonContent();
  }

  void _startCompletionTimer() {
    // Only start timer if we have materialId
    if (_materialId == null) return;
    
    // Start timer to mark lesson as complete after 5 seconds
    _completionTimer = Timer(const Duration(seconds: 5), () {
      if (!_hasMarkedComplete && mounted) {
        _markLessonComplete();
      }
    });
  }

  Future<void> _markLessonComplete() async {
    if (_hasMarkedComplete || _materialId == null) return;
    
    _hasMarkedComplete = true;
    
    final result = await _lessonService.completeLessonAudit(
      lessonId: widget.lesson.id,
      courseId: widget.courseId,
      chapterId: widget.lesson.chapterId,
      materialId: _materialId!,
      activeType: 'Content',
      completionReason: 'Completed viewing lesson content',
    );
    
    if (result['success'] == true) {
      print('✅ Lesson ${widget.lesson.id} marked as complete');
    } else {
      print('❌ Failed to mark lesson complete: ${result['message']}');
    }
  }

  Future<void> _loadLessonContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _lessonService.getLessonContent(widget.lesson.id);

    if (result['success'] == true && mounted) {
      final data = result['data'];
      setState(() {
        _videoUrl = data['videoUrl'];
        _content = data['content'];
        _materialId = data['id']; // Store material ID
        _isLoading = false;
      });
      _initializeVideo();
      
      // Start completion timer after content is loaded
      _startCompletionTimer();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Không thể tải nội dung';
      });
    }
  }

  void _initializeVideo() {
    if (_videoUrl != null && _videoUrl!.isNotEmpty) {
      try {
        final videoId = YoutubePlayer.convertUrlToId(_videoUrl!);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              enableCaption: true,
              captionLanguage: 'vi',
            ),
          );
          setState(() {
            _hasValidVideo = true;
          });
        }
      } catch (e) {
        debugPrint('Error initializing YouTube player: $e');
        setState(() {
          _hasValidVideo = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _completionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
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
                onPressed: _loadLessonContent,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          if (_hasValidVideo && _youtubeController != null) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: AppColors.primaryColor,
                  progressColors: ProgressBarColors(
                    playedColor: AppColors.primaryColor,
                    handleColor: AppColors.primaryColor,
                    bufferedColor: AppColors.primaryColor.withOpacity(0.3),
                    backgroundColor: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            // Placeholder when no video
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 48,
                    color: AppColors.textSecondaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video sẽ được cập nhật sớm',
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Lesson Title
          Text(
            widget.lesson.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),

          // Content Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.1),
                        AppColors.secondaryColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/mascot/tora_smart.png',
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nội dung bài học',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Rich Text Content
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildRichTextContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichTextContent() {
    // Use content from API, fallback to mock if empty
    final htmlContent = _content ?? '''
    <h2 style="color: #1976D2; margin-bottom: 16px;">Giới thiệu về chương này</h2>
    
    <p style="line-height: 1.6; margin-bottom: 16px;">
      Trong bài học này, chúng ta sẽ tìm hiểu về các khái niệm cơ bản và quan trọng. 
      Đây là nền tảng để bạn có thể tiến xa hơn trong việc học tập.
    </p>

    <h3 style="color: #1976D2; margin: 20px 0 12px 0;">Mục tiêu học tập:</h3>
    <ul style="margin-left: 20px; line-height: 1.8;">
      <li>Hiểu được các khái niệm cơ bản</li>
      <li>Áp dụng được kiến thức vào thực tế</li>
      <li>Phát triển tư duy logic và sáng tạo</li>
    </ul>

    <h3 style="color: #1976D2; margin: 20px 0 12px 0;">Nội dung chính:</h3>
    <ol style="margin-left: 20px; line-height: 1.8;">
      <li>
        <strong>Phần I: Lý thuyết cơ bản</strong>
        <ul style="margin-top: 8px;">
          <li>Định nghĩa và khái niệm</li>
          <li>Phân loại và đặc điểm</li>
          <li>Các nguyên lý cơ bản</li>
        </ul>
      </li>
      <li>
        <strong>Phần II: Ví dụ minh họa</strong>
        <ul style="margin-top: 8px;">
          <li>Ví dụ 1: Ứng dụng trong đời sống</li>
          <li>Ví dụ 2: Bài tập thực hành</li>
          <li>Ví dụ 3: Tình huống thực tế</li>
        </ul>
      </li>
      <li>
        <strong>Phần III: Bài tập và thực hành</strong>
        <ul style="margin-top: 8px;">
          <li>Bài tập cơ bản</li>
          <li>Bài tập nâng cao</li>
          <li>Dự án thực hành</li>
        </ul>
      </li>
    </ol>

    <div style="background: #FFF3E0; border: 1px solid #FFB74D; border-radius: 8px; padding: 16px; margin: 20px 0;">
      <p style="color: #F57C00; margin: 0; font-weight: 500;">
        ⚠️ Lưu ý quan trọng: Hãy chắc chắn bạn đã hiểu rõ các khái niệm cơ bản trước khi chuyển sang phần tiếp theo.
      </p>
    </div>

    <div style="background: #E3F2FD; border: 1px solid #64B5F6; border-radius: 8px; padding: 16px; margin: 20px 0;">
      <p style="color: #1976D2; margin: 0; font-weight: 500;">
        💡 Mẹo học tập: Thực hành thường xuyên để củng cố kiến thức.
      </p>
    </div>

    <h3 style="color: #1976D2; margin: 20px 0 12px 0;">Tài liệu tham khảo:</h3>
    <ul style="margin-left: 20px; line-height: 1.8;">
      <li>Sách giáo khoa chương trình chuẩn</li>
      <li>Các nghiên cứu khoa học liên quan</li>
      <li>Website học tập trực tuyến uy tín</li>
    </ul>
    ''';

    return Html(
      data: htmlContent,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(14),
          color: AppColors.textPrimaryColor,
          lineHeight: const LineHeight(1.6),
        ),
        "h2": Style(
          fontSize: FontSize(18),
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
          margin: Margins.only(bottom: 16),
        ),
        "h3": Style(
          fontSize: FontSize(16),
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
          margin: Margins.symmetric(vertical: 12),
        ),
        "p": Style(
          fontSize: FontSize(14),
          color: AppColors.textPrimaryColor,
          lineHeight: const LineHeight(1.6),
          margin: Margins.only(bottom: 12),
        ),
        "ul": Style(
          margin: Margins.only(left: 20, bottom: 12),
        ),
        "ol": Style(
          margin: Margins.only(left: 20, bottom: 12),
        ),
        "li": Style(
          fontSize: FontSize(14),
          color: AppColors.textPrimaryColor,
          lineHeight: const LineHeight(1.8),
          margin: Margins.only(bottom: 4),
        ),
        "strong": Style(
          fontWeight: FontWeight.bold,
        ),
        "div": Style(
          margin: Margins.symmetric(vertical: 12),
        ),
      },
    );
  }


}