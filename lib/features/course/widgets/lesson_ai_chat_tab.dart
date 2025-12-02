import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/chapter.dart';
import '../services/ai_chat_service.dart';


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
  final AiChatService _aiChatService = AiChatService();
  bool _isTyping = false;
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = true;
  String _currentStreamingMessage = '';

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
      _currentStreamingMessage = '';
    });

    if (predefinedMessage == null) {
      _messageController.clear();
    }
    _scrollToBottom();

    // Call real AI API with streaming
    try {
      await for (final chunk in _aiChatService.streamChat(
        lessonId: widget.lesson.id,
        question: messageText,
      )) {
        setState(() {
          _currentStreamingMessage += chunk;
          
          // Update the last message (AI response) if it exists
          if (_messages.isNotEmpty && !_messages.last.isUser) {
            _messages[_messages.length - 1] = ChatMessage(
              text: _currentStreamingMessage,
              isUser: false,
              timestamp: _messages.last.timestamp,
            );
          } else {
            // Create new AI message
            _messages.add(
              ChatMessage(
                text: _currentStreamingMessage,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          }
        });
        
        _scrollToBottom();
      }
      
      // Stream completed
      setState(() {
        _isTyping = false;
        _currentStreamingMessage = '';
      });
    } catch (e) {
      print('❌ Error in streaming: $e');
      
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Xin lỗi, đã xảy ra lỗi khi kết nối với AI. Vui lòng thử lại.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
        _currentStreamingMessage = '';
      });
    }

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
