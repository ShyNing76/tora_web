import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../models/chapter.dart';
import '../services/lesson_service.dart';

class LessonSummaryTab extends StatefulWidget {
  final Lesson lesson;
  final String courseId;

  const LessonSummaryTab({
    super.key,
    required this.lesson,
    required this.courseId,
  });

  @override
  State<LessonSummaryTab> createState() => _LessonSummaryTabState();
}

class _LessonSummaryTabState extends State<LessonSummaryTab> {
  final LessonService _lessonService = LessonService();
  
  bool _isLoading = true;
  String? _errorMessage;
  String? _summaryContent;
  String? _materialId; // Store material ID from API response
  
  Timer? _completionTimer;
  bool _hasMarkedComplete = false;

  @override
  void initState() {
    super.initState();
    _loadLessonSummary();
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
      activeType: 'Summary',
      completionReason: 'Completed viewing lesson summary',
    );
    
    if (result['success'] == true) {
      print('✅ Lesson ${widget.lesson.id} marked as complete');
    } else {
      print('❌ Failed to mark lesson complete: ${result['message']}');
    }
  }

  Future<void> _loadLessonSummary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _lessonService.getLessonSummary(widget.lesson.id);

    if (result['success'] == true && mounted) {
      final data = result['data'];
      setState(() {
        _summaryContent = data['content'];
        _materialId = data['id']; // Store material ID
        _isLoading = false;
      });
      
      // Start completion timer after summary is loaded
      _startCompletionTimer();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Không thể tải tóm tắt';
      });
    }
  }

  @override
  void dispose() {
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
                onPressed: _loadLessonSummary,
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
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.8),
                  AppColors.secondaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Image.asset(  'assets/images/mascot/tora_note.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tóm tắt bài học',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nội dung bài học sẽ được Tora tóm tắt thành các ý chính để bạn có thể dễ dàng theo dõi và hiểu bài học hơn.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Summary Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildSummaryContent(),
          ),

          const SizedBox(height: 24),

          // Key Points Section
          _buildKeyPointsSection(),
        ],
      ),
    );
  }

  Widget _buildSummaryContent() {
    // Use summary from API, fallback to mock if empty
    final htmlSummary = _summaryContent ?? '''
    <h3 style="color: #1976D2; margin-bottom: 16px;">Tóm tắt chính:</h3>
    
    <p style="line-height: 1.6; margin-bottom: 16px;">
      Bài học này giới thiệu về các <strong>khái niệm cơ bản</strong> và 
      <strong>nguyên lý quan trọng</strong> mà người học cần nắm vững.
    </p>

    <h4 style="color: #1976D2; margin: 20px 0 12px 0;">Những điểm quan trọng:</h4>
    <ul style="margin-left: 20px; line-height: 1.8;">
      <li><strong>Định nghĩa cốt lõi</strong>: Hiểu rõ bản chất và ý nghĩa của các khái niệm</li>
      <li><strong>Phân loại rõ ràng</strong>: Nắm được cách phân chia và đặc điểm của từng loại</li>
      <li><strong>Ứng dụng thực tế</strong>: Biết cách áp dụng kiến thức vào cuộc sống hàng ngày</li>
      <li><strong>Tư duy logic</strong>: Phát triển khả năng suy luận và giải quyết vấn đề</li>
    </ul>

    <h4 style="color: #1976D2; margin: 20px 0 12px 0;">Kết quả đạt được sau bài học:</h4>
    <ol style="margin-left: 20px; line-height: 1.8;">
      <li>Hiểu được 100% các khái niệm cơ bản</li>
      <li>Có thể giải thích cho người khác một cách dễ hiểu</li>
      <li>Áp dụng được vào các bài tập thực hành</li>
      <li>Sẵn sàng cho các chương tiếp theo</li>
    </ol>

    <div style="background: #E3F2FD; border: 1px solid #64B5F6; border-radius: 8px; padding: 16px; margin: 20px 0;">
      <p style="color: #1976D2; margin: 0; font-weight: 500;">
        💡 <strong>Lưu ý</strong>: Đây chỉ là bước đầu, hãy tiếp tục ôn tập để củng cố kiến thức!
      </p>
    </div>
    ''';

    return Html(
      data: htmlSummary,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(14),
          color: AppColors.textPrimaryColor,
          lineHeight: const LineHeight(1.6),
        ),
        "h3": Style(
          fontSize: FontSize(18),
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
          margin: Margins.only(bottom: 16),
        ),
        "h4": Style(
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

  Widget _buildKeyPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Điểm nhấn quan trọng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildKeyPointCard(
          icon: Icons.lightbulb_outline,
          color: AppColors.warningColor,
          title: 'Khái niệm cốt lõi',
          content: 'Nắm vững định nghĩa và bản chất của vấn đề',
        ),
        const SizedBox(height: 12),
        
        _buildKeyPointCard(
          icon: Icons.trending_up,
          color: AppColors.successColor,
          title: 'Phương pháp tiếp cận',
          content: 'Áp dụng tư duy logic và hệ thống trong học tập',
        ),
        const SizedBox(height: 12),
        
        _buildKeyPointCard(
          icon: Icons.psychology,
          color: AppColors.infoColor,
          title: 'Ứng dụng thực tế',
          content: 'Liên kết kiến thức với cuộc sống hàng ngày',
        ),
        const SizedBox(height: 12),
        
        _buildKeyPointCard(
          icon: Icons.school,
          color: AppColors.primaryColor,
          title: 'Chuẩn bị cho bước tiếp theo',
          content: 'Nền tảng vững chắc để học các chương nâng cao',
        ),
      ],
    );
  }

  Widget _buildKeyPointCard({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}