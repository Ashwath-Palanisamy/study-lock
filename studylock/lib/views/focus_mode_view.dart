import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:studylock/components/app_section.dart';
import 'package:studylock/components/app_text.dart';
import 'package:studylock/models/focus_timer_model.dart';
import 'package:studylock/riverpod/focus_provider.dart';

class FocusModeView extends ConsumerStatefulWidget {
  const FocusModeView({super.key});

  @override
  ConsumerState<FocusModeView> createState() => _FocusModeViewState();
}

class _FocusModeViewState extends ConsumerState<FocusModeView>
    with WidgetsBindingObserver {
  double _selectedMinutes = 25;
  bool _isAccessibilityEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAccessibilityPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Re-check permission whenever the user returns from system settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAccessibilityPermission();
    }
  }

  Future<void> _checkAccessibilityPermission() async {
    final enabled =
        await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    if (mounted) {
      setState(() {
        _isAccessibilityEnabled = enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(focusProvider);
    final isIdle = session.state == FocusSessionState.idle;

    final displaySeconds = isIdle
        ? (_selectedMinutes * 60).toInt()
        : session.remainingSeconds;
    final minutes = (displaySeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (displaySeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('Focus Mode')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ⚠️ Accessibility Warning Banner (Shown if permission is off)
              if (!_isAccessibilityEnabled) ...[
                AppSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Permission Required',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'StudyLock needs Accessibility permission to block distracting apps during focus sessions.\n\n'
                        'How to enable:\n'
                        '1. Tap the button below.\n'
                        '2. Look for Installed apps (or Downloaded apps).\n'
                        '3. Find StudyLock and turn it On.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade800,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await FlutterAccessibilityService.requestAccessibilityPermission();
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Enable Accessibility Service'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Main Page widgets
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
                    AppText.body('Status: ${session.state.name.toUpperCase()}'),
                    const SizedBox(height: 24),

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
                        onPressed: _isAccessibilityEnabled
                            ? () {
                                ref
                                    .read(focusProvider.notifier)
                                    .startSessionTimer(
                                      _selectedMinutes.toInt(),
                                    );
                              }
                            : null, // Disable button if accessibility is off
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Focus Session'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
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
