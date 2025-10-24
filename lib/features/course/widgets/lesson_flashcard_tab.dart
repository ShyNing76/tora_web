import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../models/chapter.dart';
import '../models/flashcard.dart';
import '../services/lesson_service.dart';

class LessonFlashcardTab extends StatefulWidget {
  final Lesson lesson;
  final String courseId;

  const LessonFlashcardTab({
    super.key,
    required this.lesson,
    required this.courseId,
  });

  @override
  State<LessonFlashcardTab> createState() => _LessonFlashcardTabState();
}

class _LessonFlashcardTabState extends State<LessonFlashcardTab>
    with TickerProviderStateMixin {
  final LessonService _lessonService = LessonService();
  
  PageController _pageController = PageController();
  int _currentIndex = 0;
  List<Flashcard> _flashcards = [];
  List<bool> _isFlipped = [];
  List<AnimationController> _flipControllers = [];
  List<Animation<double>> _flipAnimations = [];
  
  bool _isLoading = true;
  String? _errorMessage;
  String? _materialId; // Store material ID from API response
  
  Timer? _completionTimer;
  bool _hasMarkedComplete = false;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
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
      activeType: 'Flashcard',
      completionReason: 'Completed viewing flashcards',
    );
    
    if (result['success'] == true) {
      print('✅ Lesson ${widget.lesson.id} marked as complete');
    } else {
      print('❌ Failed to mark lesson complete: ${result['message']}');
    }
  }

  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _lessonService.getLessonFlashcards(widget.lesson.id);

    if (result['success'] == true && mounted) {
      final data = result['data'];
      
      // Store material ID
      _materialId = data['id'];
      
      // API returns single flashcard, convert to list
      final flashcard = Flashcard(
        id: data['id'],
        question: data['question'],
        answer: data['answer'],
      );
      
      setState(() {
        _flashcards = [flashcard];
        _isLoading = false;
      });
      
      _initializeAnimations();
      
      // Start completion timer after flashcards are loaded
      _startCompletionTimer();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] ?? 'Không thể tải flashcard';
      });
    }
  }

  void _initializeAnimations() {

    if (_flashcards.isEmpty) return;
    
    _isFlipped = List.generate(_flashcards.length, (index) => false);

    // Initialize animation controllers
    for (int i = 0; i < _flashcards.length; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _flipControllers.add(controller);
      _flipAnimations.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      );
    }
  }

  void _flipCard(int index) {
    if (_flipControllers[index].isAnimating) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isFlipped[index] = !_isFlipped[index];
    });

    if (_isFlipped[index]) {
      _flipControllers[index].forward();
    } else {
      _flipControllers[index].reverse();
    }
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _completionTimer?.cancel();
    for (var controller in _flipControllers) {
      controller.dispose();
    }
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
                onPressed: _loadFlashcards,
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
    
    if (_flashcards.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIndex + 1}/${_flashcards.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${((_currentIndex + 1) / _flashcards.length * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Progress bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.borderColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width:
                        constraints.maxWidth *
                        ((_currentIndex + 1) / _flashcards.length),
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Flashcard area
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                // Reset flip state when changing cards
                _isFlipped[index] = false;
                _flipControllers[index].reset();
              });
            },
            itemCount: _flashcards.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildFlashcard(index),
              );
            },
          ),
        ),

        // Controls
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControlButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: _currentIndex > 0 ? _previousCard : null,
                    tooltip: 'Thẻ trước',
                  ),
                  _buildControlButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: _currentIndex < _flashcards.length - 1
                        ? _nextCard
                        : null,
                    tooltip: 'Thẻ sau',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcard(int index) {
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedBuilder(
        animation: _flipAnimations[index],
        builder: (context, child) {
          final isShowingFront = _flipAnimations[index].value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimations[index].value * 3.14159),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: isShowingFront
                  ? _buildCardFront(_flashcards[index])
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildCardBack(_flashcards[index]),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(Flashcard flashcard) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/images/mascot/tora_confuse.png',
              width: 100,
              height: 100,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            flashcard.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Chạm để xem đáp án',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Flashcard flashcard) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: Image.asset(
              'assets/images/mascot/tora_smart.png',
              width: 100,
              height: 100,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            flashcard.answer,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Chạm để ẩn đáp án',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.successColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isPrimary = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isPrimary ? AppColors.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: isPrimary ? 4 : 2,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isPrimary
                  ? null
                  : Border.all(color: AppColors.borderColor),
            ),
            child: Icon(
              icon,
              color: isPrimary
                  ? Colors.white
                  : onPressed != null
                  ? AppColors.textPrimaryColor
                  : AppColors.textSecondaryColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: AppColors.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có flashcard nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Flashcards sẽ được cập nhật sớm để giúp bạn ghi nhớ tốt hơn',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
