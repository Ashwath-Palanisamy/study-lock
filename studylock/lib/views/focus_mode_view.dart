import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylock/components/app_section.dart';
import 'package:studylock/components/app_text.dart';
import 'package:studylock/models/focus_timer_model.dart';
import 'package:studylock/riverpod/focus_provider.dart';

class FocusModeView extends ConsumerStatefulWidget {
  const FocusModeView({super.key});

  @override
  ConsumerState<FocusModeView> createState() => _FocusModeViewState();
}

class _FocusModeViewState extends ConsumerState<FocusModeView> {
  // Local state to track the user's chosen duration before starting
  double _selectedMinutes = 25;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(focusProvider);
    final isIdle = session.state == FocusSessionState.idle;

    // Show preview of selected minutes when idle, or actual remaining time when running
    final displaySeconds = isIdle ? (_selectedMinutes * 60).toInt() : session.remainingSeconds;
    final minutes = (displaySeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (displaySeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Mode')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              AppSection(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Timer Display
                    Text(
                      '$minutes:$seconds',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // State label
                    AppText.body('Status: ${session.state.name.toUpperCase()}'),
                    const SizedBox(height: 24),

                    // Controls switch dynamically based on whether the timer is running
                    if (isIdle) ...[
                      Text('Set Duration: ${_selectedMinutes.toInt()} minutes'),
                      Slider(
                        value: _selectedMinutes,
                        min: 5,
                        max: 60,
                        divisions: 11, 
                        label: '${_selectedMinutes.toInt()} min',
                        onChanged: (value) {
                          setState(() {
                            _selectedMinutes = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(focusProvider.notifier).startSessionTimer(_selectedMinutes.toInt());
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Focus Session'),
                        style: ElevatedButton.styleFrom(foregroundColor: Colors.blue),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,foregroundColor: Colors.white),
                        onPressed: () {
                          ref.read(focusProvider.notifier).resetSessionTimer();
                        },
                        icon: const Icon(Icons.stop),
                        label: const Text('Reset Session'),
                        
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}