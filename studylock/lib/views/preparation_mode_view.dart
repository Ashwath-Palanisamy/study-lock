import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylock/components/app_buttons.dart';
import 'package:studylock/components/app_section.dart';
import 'package:studylock/components/app_text.dart';
import 'package:studylock/riverpod/ai_file_analysis.dart';
import 'package:studylock/views/scanning_page_view.dart';

class PreparationModeView extends ConsumerWidget {
  const PreparationModeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentfile = ref.watch(selectedFileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preparation Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                        const AppText.title('Upload Study Material'),
                        const SizedBox(height: 8),
                        const AppText.body(
                          'Upload your syllabus or notes to begin.',
                        ),
                        const SizedBox(height: 24),

                        // Upload section card
                        AppSection(
                          child: InkWell(
                            onTap: () async {
                              try {
                                final result = await FilePicker.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf', 'txt', 'docx'],
                                );

                                if (result.isNotEmpty) {
                                  ref
                                      .read(selectedFileProvider.notifier)
                                      .setFile(result.single);
                                }
                              } catch (e) {
                                debugPrint(
                                  'File selection cancelled or error: $e',
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.upload,
                                      size: 48,
                                      color: Colors.lightBlueAccent,
                                    ),
                                    const SizedBox(height: 16),
                                    currentfile != null
                                        ? AppText.heading(
                                            'Selected file: ${currentfile.name}',
                                          )
                                        : const AppText.heading(
                                            'Click to upload PDF',
                                          ),
                                    const SizedBox(height: 6),
                                    const AppText.body(
                                      'Supports PDF, TXT, or DOCX',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Continue button
                        const SizedBox(height: 16),
                        AppButtons(
                          onPressed: (currentfile == null)
                              ? null
                              : () async {
                                  ref
                                      .read(aiFileAnalysisProvider.notifier)
                                      .uploadFileCall();

                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ScanningPageView(),
                                    ),
                                  );
                                  ref
                                      .read(selectedFileProvider.notifier)
                                      .clearFile();
                                },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue'),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_right_alt),
                            ],
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
