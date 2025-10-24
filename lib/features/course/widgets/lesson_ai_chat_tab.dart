import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/chapter.dart';


class LessonAiChatTab extends StatefulWidget {
  final Lesson lesson;

  const LessonAiChatTab({super.key, required this.lesson});

  @override
  State<LessonAiChatTab> createState() => _LessonAiChatTabState();
}

class _LessonAiChatTabState extends State<LessonAiChatTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = true;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            'Xin chào! Tôi là AI trợ lý của bạn. Tôi có thể giúp bạn giải đáp các câu hỏi về bài học "${widget.lesson.title}". Hãy hỏi tôi bất cứ điều gì bạn muốn biết!',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _sendMessage([String? predefinedMessage]) async {
    final messageText = predefinedMessage ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Hide suggestions after first user message
    setState(() {
      _showSuggestions = false;
      _messages.add(
        ChatMessage(text: messageText, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    if (predefinedMessage == null) {
      _messageController.clear();
    }
    _scrollToBottom();

    // Simulate AI response
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _messages.add(
        ChatMessage(
          text: _generateAiResponse(messageText),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = false;
    });

    _scrollToBottom();
  }

  Widget _buildSuggestionButtons() {
    final suggestions = [
      'Giải thích khái niệm chính trong bài học này',
      'Cho tôi ví dụ thực tế về nội dung đã học',
      'Tôi có thể ôn tập như thế nào?',
      'Phần nào trong bài học quan trọng nhất?',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gợi ý câu hỏi:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return InkWell(
                onTap: () => _sendMessage(suggestion),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _generateAiResponse(String userMessage) {
    // Mock AI responses based on common patterns
    final message = userMessage.toLowerCase();

    if (message.contains('gì') ||
        message.contains('what') ||
        message.contains('định nghĩa')) {
      return 'Đây là một câu hỏi rất hay! Dựa trên nội dung bài học "${widget.lesson.title}", tôi có thể giải thích rằng:\n\n• Khái niệm cốt lõi được đề cập trong bài học này có ý nghĩa quan trọng trong việc xây dựng nền tảng kiến thức\n• Nó liên kết chặt chẽ với các chủ đề khác trong chương trình học\n• Việc hiểu rõ điều này sẽ giúp bạn dễ dàng tiếp thu các bài học tiếp theo\n\nBạn có muốn tôi giải thích chi tiết hơn về phần nào không?';
    }

    if (message.contains('tại sao') ||
        message.contains('why') ||
        message.contains('lý do')) {
      return 'Câu hỏi "tại sao" rất quan trọng để hiểu bản chất vấn đề!\n\nLý do chính:\n🔹 Đây là nền tảng cần thiết cho việc học tập hiệu quả\n🔹 Giúp bạn kết nối kiến thức mới với kinh nghiệm đã có\n🔹 Tạo ra sự hiểu biết sâu sắc thay vì chỉ học thuộc lòng\n\nViệc hiểu rõ "tại sao" sẽ giúp bạn áp dụng kiến thức một cách linh hoạt trong nhiều tình huống khác nhau.';
    }

    if (message.contains('cách') ||
        message.contains('làm thế nào') ||
        message.contains('how')) {
      return 'Để thực hiện hiệu quả, bạn có thể làm theo các bước sau:\n\n📝 **Bước 1:** Ôn lại nội dung bài học và ghi chú những điểm quan trọng\n\n📝 **Bước 2:** Thực hành qua các ví dụ cụ thể và flashcard\n\n📝 **Bước 3:** Áp dụng kiến thức vào các tình huống thực tế\n\n📝 **Bước 4:** Tự kiểm tra bằng cách giải thích lại cho người khác\n\nHãy bắt đầu từ bước nào bạn cảm thấy thoải mái nhất!';
    }

    if (message.contains('ví dụ') ||
        message.contains('example') ||
        message.contains('minh họa')) {
      return 'Đây là một số ví dụ minh họa cho nội dung bài học:\n\n💡 **Ví dụ 1:** Trong thực tế, bạn có thể gặp tình huống tương tự khi...\n\n💡 **Ví dụ 2:** Một cách tiếp cận khác là áp dụng nguyên lý này vào...\n\n💡 **Ví dụ 3:** Khi đối mặt với vấn đề phức tạp, hãy nghĩ về...\n\nNhững ví dụ này sẽ giúp bạn hiểu rõ hơn cách áp dụng kiến thức vào thực tiễn. Bạn có muốn tôi phân tích sâu hơn về ví dụ nào không?';
    }

    if (message.contains('khó') ||
        message.contains('không hiểu') ||
        message.contains('confused')) {
      return 'Tôi hiểu rằng đôi khi kiến thức mới có thể khó tiếp thu. Đừng lo lắng, điều này rất bình thường!\n\n🎯 **Gợi ý học tập:**\n• Chia nhỏ nội dung thành các phần dễ hiểu hơn\n• Tìm hiểu từ những khái niệm cơ bản nhất trước\n• Sử dụng flashcard để ghi nhớ từ khóa quan trọng\n• Thực hành nhiều lần với các bài tập khác nhau\n\nHãy cho tôi biết cụ thể phần nào bạn đang gặp khó khăn để tôi có thể hỗ trợ tốt hơn?';
    }

    if (message.contains('bài tập') ||
        message.contains('practice') ||
        message.contains('luyện tập')) {
      return 'Rất tốt khi bạn muốn luyện tập! Đây là một số gợi ý:\n\n📚 **Các dạng bài tập phù hợp:**\n• Flashcard để ghi nhớ khái niệm cốt lõi\n• Câu hỏi trắc nghiệm để kiểm tra hiểu biết\n• Bài tập thực hành áp dụng lý thuyết\n• Phân tích tình huống thực tế\n\nViệc luyện tập thường xuyên sẽ giúp bạn nắm vững kiến thức và tự tin hơn. Bạn muốn bắt đầu với dạng bài tập nào?';
    }

    // Default responses for general questions
    final defaultResponses = [
      'Cảm ơn bạn đã đặt câu hỏi! Dựa trên nội dung bài học "${widget.lesson.title}", tôi nghĩ rằng điều này liên quan đến các khái niệm cốt lõi mà chúng ta đã học. Bạn có thể chia sẻ cụ thể hơn về phần nào bạn muốn tìm hiểu không?',

      'Đây là một câu hỏi thú vị! Trong bài học này, chúng ta đã được tìm hiểu về nhiều khía cạnh quan trọng. Để tôi có thể hỗ trợ bạn tốt nhất, bạn có thể làm rõ hơn về điều bạn đang thắc mắc không?',

      'Tôi rất vui được giúp bạn! Nội dung bài học "${widget.lesson.title}" chứa đựng nhiều kiến thức bổ ích. Bạn có thể kể cho tôi biết cụ thể bạn đang gặp khó khăn ở phần nào để tôi có thể đưa ra lời giải thích phù hợp nhất?',
    ];

    return defaultResponses[DateTime.now().millisecond %
        defaultResponses.length];
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          // Chat messages area
          Expanded(
            child: Column(
              children: [
                // Chat messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),

                // Suggestion buttons (show when no messages or only welcome message)
                if (_messages.length <= 1 && _showSuggestions)
                  _buildSuggestionButtons(),
              ],
            ),
          ),

          // Simple Input area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 28, right: 28, bottom: 8, top: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.attachment,
                            color: AppColors.primaryColor,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        maxLines: 5,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                        decoration: const InputDecoration(
                          hintText: 'Hỏi Tora bất cứ điều gì...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        onChanged: (value) {
                          setState(() {
                            // Trigger rebuild to update send button state
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: _messageController.text.trim().isNotEmpty 
                            ? _sendMessage 
                            : null,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _messageController.text.trim().isNotEmpty
                                ? AppColors.primaryColor
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Image.asset(
              'assets/images/mascot/tora_chat.png',
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 18),
                ),
                border: message.isUser
                    ? null
                    : Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GptMarkdown(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: message.isUser
                          ? Colors.white
                          : AppColors.textPrimaryColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Image.asset(
            'assets/images/mascot/tora_chat.png',
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                18,
              ).copyWith(bottomLeft: const Radius.circular(4)),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.textSecondaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
