import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylock/riverpod/ai_file_analysis.dart';
import 'package:studylock/api/ai_functions.dart';

class McqPageView extends ConsumerStatefulWidget {
  const McqPageView({super.key});

  @override
  ConsumerState<McqPageView> createState() => _McqPageViewState();
}

class _McqPageViewState extends ConsumerState<McqPageView> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _mcqData;
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _fetchMcqs();
  }

  Future<void> _fetchMcqs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fileUri = ref.read(aiFileAnalysisProvider);
      final aiService = AiFunctions();
      final data = await aiService.getMcqs(fileUri);

      setState(() {
        _mcqData = data;
        _isLoading = false;
        _currentIndex = 0;
        _selectedOptionIndex = null;
        _isAnswered = false;
        _score = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _questions {
    if (_mcqData == null) return [];
    return _mcqData!['mcqs'] ?? _mcqData!['questions'] ?? [];
  }

  void _handleOptionSelected(int optionIndex, int correctIndex) {
    if (_isAnswered) return;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _isAnswered = true;
      if (optionIndex == correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      } else {
        _currentIndex = _questions.length;
      }
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _isAnswered = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Practice MCQs'),
        actions: [
          if (!_isLoading && _errorMessage == null && _questions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchMcqs,
              tooltip: 'Regenerate MCQs', // Tooltip added here
            ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Opacity(
                  opacity: 0.3 + (0.7 * (value - 0.5).abs() * 2),
                  child: child,
                );
              },
              child: const Icon(
                Icons.quiz_rounded,
                size: 64,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Analyzing document & generating MCQs...',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load MCQs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchMcqs,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    final questions = _questions;
    if (questions.isEmpty) {
      return const Center(child: Text('No MCQs found in the response.'));
    }

    if (_currentIndex >= questions.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Quiz Completed!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Score: $_score / ${questions.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetQuiz,
              child: const Text('Restart Quiz'),
            ),
          ],
        ),
      );
    }

    final currentQ = questions[_currentIndex];
    final questionText = currentQ['question'] ?? currentQ['text'] ?? '';
    final options = List<String>.from(
      currentQ['options'] ?? currentQ['choices'] ?? [],
    );
    final explanation =
        currentQ['explanation'] ??
        currentQ['reason'] ??
        'No explanation provided.';

    int correctIndex = 0;
    if (currentQ.containsKey('correct_index')) {
      correctIndex = currentQ['correct_index'];
    } else if (currentQ.containsKey('answer_index')) {
      correctIndex = currentQ['answer_index'];
    } else if (currentQ.containsKey('answer')) {
      var ans = currentQ['answer'];
      if (ans is int) {
        correctIndex = ans;
      } else if (ans is String) {
        correctIndex = options.indexOf(ans);
        if (correctIndex < 0) correctIndex = 0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: (_currentIndex + 1) / questions.length,
          backgroundColor: Colors.grey[800],
        ),
        const SizedBox(height: 16),
        Text(
          'Question ${_currentIndex + 1} of ${questions.length}',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          questionText,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              ...List.generate(options.length, (index) {
                Color cardColor = Colors.grey[850]!;
                if (_isAnswered) {
                  if (index == correctIndex) {
                    cardColor = Colors.green.withValues(alpha: 0.3);
                  } else if (index == _selectedOptionIndex) {
                    cardColor = Colors.red.withValues(alpha: 0.3);
                  }
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAnswered && index == correctIndex
                          ? Colors.green
                          : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    title: Text(options[index]),
                    onTap: () => _handleOptionSelected(index, correctIndex),
                  ),
                );
              }),

              if (_isAnswered) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Explanation:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        explanation,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_isAnswered) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(
                _currentIndex < questions.length - 1
                    ? 'Next Question'
                    : 'View Results',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
