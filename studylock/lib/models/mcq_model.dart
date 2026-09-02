class McqItem {
  final int id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  McqItem({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory McqItem.fromJson(Map<String, dynamic> json) {
    return McqItem(
      id: json['id'] as int,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correct_answer'] as String, 
      explanation: json['explanation'] as String,
    );
  }
}


class McqState {
  final List<McqItem> questions;
  final Map<int, String> selectedAnswers; 

  McqState({
    required this.questions,
    this.selectedAnswers = const {},
  });

  
  McqState copyWith({
    List<McqItem>? questions,
    Map<int, String>? selectedAnswers,
  }) {
    return McqState(
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}