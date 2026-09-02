import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylock/api/ai_functions.dart';
import 'package:studylock/riverpod/ai_file_analysis.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

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
    final aiService = AiFunctions();

    state = [...state, ChatMessage(text: '', isUser: false)];

    try {
      await for (final chunk in aiService.chatAPI(fileuri, messageText)) {
        final updatedMessages = [...state];
        final lastMessage = updatedMessages.last;
        updatedMessages[updatedMessages.length - 1] = ChatMessage(
          text: lastMessage.text + chunk,
          isUser: false,
        );
        state = updatedMessages;
      }
    } catch (e) {
      final updatedMessages = [...state];
      updatedMessages[updatedMessages.length - 1] = ChatMessage(
        text: 'Error getting response from server.',
        isUser: false,
      );
      state = updatedMessages;
    }
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, List<ChatMessage>>(() {
  return AiChatNotifier();
});