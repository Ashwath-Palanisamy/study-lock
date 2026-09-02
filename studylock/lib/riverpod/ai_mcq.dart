import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylock/api/ai_functions.dart';
import 'package:studylock/models/mcq_model.dart';

final aiServiceProvider = Provider<AiFunctions>((ref) {
  return AiFunctions();
});

class AiMcqNotifier extends AsyncNotifier<McqState> {
  AiMcqNotifier(this.fileUri);
  final String fileUri;

  @override
  Future<McqState> build() async {
    
    final aiService = ref.read(aiServiceProvider);
    
    final responseData = await aiService.getMcqs(fileUri);
    final List<dynamic> rawMcqs = responseData['mcqs'] ?? [];
    
    final questions = rawMcqs
        .map((json) => McqItem.fromJson(json as Map<String, dynamic>))
        .toList();

    return McqState(questions: questions);
  }

  void selectOption(int questionIndex, String selectedOption) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedAnswers = Map<int, String>.from(currentState.selectedAnswers);
    updatedAnswers[questionIndex] = selectedOption;

    state = AsyncData(currentState.copyWith(selectedAnswers: updatedAnswers));
  }
}


final aiMcqProvider =
    AsyncNotifierProvider.family<AiMcqNotifier, McqState, String>(
  AiMcqNotifier.new,
);