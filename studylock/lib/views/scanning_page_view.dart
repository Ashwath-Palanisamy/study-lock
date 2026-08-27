import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylock/components/app_section.dart';
import 'package:studylock/components/app_text.dart';
import 'package:studylock/riverpod/ai_file_analysis.dart';
import 'package:studylock/views/choice_page_view.dart';

class ScanningPageView extends ConsumerStatefulWidget {
  const ScanningPageView({super.key});

  @override
  ConsumerState<ScanningPageView> createState() => _ScanningPageViewState();
}

class _ScanningPageViewState extends ConsumerState<ScanningPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(aiFileAnalysisProvider, (previous, next) {
      if (next.contains('error') || next.contains('Please')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Upload Error'),
            content: Text('Unable to upload file.\nPlease check your network connection'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        Navigator.pop(context); 
      } else if (next.isNotEmpty && next != 'Uploading...') {
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChoicePageView()),
        );
      }
    });

    final currentfile = ref.watch(selectedFileProvider);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.title('Analyzing ${currentfile?.name}'),
                        const SizedBox(height: 8),
                        const AppText.body(
                          'Connecting to AI to process your syllabus.',
                        ),
                        const SizedBox(height: 32),
                        AppSection(
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 48.0,
                                horizontal: 24,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 150,
                                    width: 120,
                                    child: Stack(
                                      children: [
                                        // 1. The Document Icon
                                        const Center(
                                          child: Icon(
                                            Icons.description_outlined,
                                            size: 120,
                                            color: Colors.white24,
                                          ),
                                        ),
                                        // 2. The Animated Scanning Line
                                        AnimatedBuilder(
                                          animation: _controller,
                                          builder: (context, child) {
                                            return Align(
                                              alignment: Alignment(
                                                0.0,
                                                _controller.value * 2 - 1.0,
                                              ),
                                              child: child!,
                                            );
                                          },
                                          child: Container(
                                            height: 4,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlueAccent
                                                  .withValues(alpha: 0.8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.lightBlueAccent
                                                      .withValues(alpha: 0.6),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 32),
                                  const AppText.heading('AI is reading...'),
                                  const SizedBox(height: 8),
                                  const AppText.body(
                                    'Extracting modules and topics',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
