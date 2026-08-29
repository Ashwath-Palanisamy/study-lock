import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; 
import 'package:studylock/riverpod/ai_chat.dart';

class ExplainTopicsView extends ConsumerStatefulWidget {
  const ExplainTopicsView({super.key});

  @override
  ConsumerState<ExplainTopicsView> createState() => _ExplainTopicsViewState();
}

class _ExplainTopicsViewState extends ConsumerState<ExplainTopicsView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAiThinking = false; // Tracks if AI is currently loading a response

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Smooth scroll to the bottom of the list
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

  Future<void> _handleSendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() => _isAiThinking = true);
    _scrollToBottom();

    // Call the notifier to send the message
    await ref.read(aiChatProvider.notifier).sendMessage(text);

    setState(() => _isAiThinking = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ask AI')),
      body: Column(
        children: [
          // Expanded chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (_isAiThinking ? 1 : 0),
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                // Display animated thinking bubble at the bottom if AI is processing
                if (index == messages.length && _isAiThinking) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: AiThinkingBubble(),
                    ),
                  );
                }

                final message = messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUser ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),

                    // Use Markdown for AI responses, plain text for User
                    child: message.isUser
                        ? Text(
                            message.text,
                            style: const TextStyle(color: Colors.white),
                          )
                        : MarkdownBody(
                            data: message.text,
                            styleSheet: MarkdownStyleSheet.fromTheme(
                              Theme.of(context),
                            ).copyWith(
                              p: const TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          
          // Input field and send button container at the bottom
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask something about the file...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _handleSendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: _isAiThinking ? null : _handleSendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple widget for the animated "AI is thinking" bouncing dots
class AiThinkingBubble extends StatefulWidget {
  const AiThinkingBubble({super.key});

  @override
  State<AiThinkingBubble> createState() => _AiThinkingBubbleState();
}

class _AiThinkingBubbleState extends State<AiThinkingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller,
              curve: Interval(index * 0.2, 0.6 + index * 0.2, curve: Curves.easeInOut),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}