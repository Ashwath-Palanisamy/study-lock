import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylock/api/ai_chat_and_analysis.dart';
import 'package:studylock/riverpod/ai_file_analysis.dart';

// 1. Simple Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

//  AI Chat Notifier to handle message history and backend calls
class AiChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [
     ChatMessage(
        text: '👋 Hello! \nI am your personal study partner. Ask me any question and I will explain it to you',
        isUser: false,
      ),
    ];
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    state = [...state, ChatMessage(text: messageText, isUser: true)];

    final fileuri = ref.read(aiFileAnalysisProvider);
    final aiService = AiChatAnalysis();

    try {
      final aiResponseText = await aiService.chatAPI(fileuri, messageText);

      // Add AI response to state
      state = [...state, ChatMessage(text: aiResponseText, isUser: false)];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(text: 'Error getting response from server.', isUser: false),
      ];
    }
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, List<ChatMessage>>(() {
  return AiChatNotifier();
});
