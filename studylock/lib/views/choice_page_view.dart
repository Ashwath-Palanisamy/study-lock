import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylock/components/app_buttons.dart';
import 'package:studylock/components/app_section.dart';
import 'package:studylock/components/app_text.dart';
import 'package:studylock/riverpod/ai_chat.dart';
import 'package:studylock/views/explain_topics_view.dart';
import 'package:studylock/views/mcq_page_view.dart';

class ChoicePageView extends ConsumerWidget {
  const ChoicePageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      // Show warning when leaving the page
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave?'),
            content: const Text(
              'Are you sure you want to leave the page? \n\nLeaving this page will clear your chats and MCQ(s)',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Stay!'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Leave!'),
              ),
            ],
          ),
        );

        if (shouldPop == true && context.mounted) {
          ref.invalidate(aiChatProvider);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Choose an option'), actions: [
            
          ],),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      // Body content
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.title('Choose one'),
                        AppText.body(
                          'Choose what you want your study partner to do?',
                        ),

                        // option sections
                        SizedBox(height: 16),
                        AppSection(
                          child: Column(
                            children: [
                              AppButtons(
                                child: Text('Explain Topics?'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExplainTopicsView(),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: 16),

                              AppButtons(
                                child: Text('Test you with MCQs?'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const McqPageView(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
