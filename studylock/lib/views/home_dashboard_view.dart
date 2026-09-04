import 'package:flutter/material.dart';
import 'package:studylock/components/app_section.dart';
import 'package:studylock/components/app_text.dart';
import 'package:studylock/views/focus_mode_view.dart';
import 'package:studylock/views/preparation_mode_view.dart';

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  final List<String> _studyTips = const [
    "💡 Tip: Break your study session into 25-minute chunks with short 5-minute breaks.",
    "🚀 Focus: Put your phone out of reach to dramatically reduce cognitive distraction.",
    "📚 Tip: Active recall (testing yourself) is twice as effective as re-reading notes.",
    "☕ Reminder: Hydration keeps your brain sharp. Grab a glass of water!",
    "🎯 Focus: Clear your desk of everything except what you need for this session.",
  ];

  @override
  Widget build(BuildContext context) {
    final String currentTip =
        _studyTips[DateTime.now().day % _studyTips.length];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const AppText.title('Welcome back!'),
                    const SizedBox(height: 6),
                    const AppText.body(
                      "Ready for a distraction-free session today?",
                    ),
                    const SizedBox(height: 24),

                    // Main Action Cards 
                    Row(
                      children: [
                        Expanded(
                          child: _buildHeroModeCard(
                            context,
                            icon: Icons.shield_outlined,
                            label: 'Focus Mode',
                            subtitle: 'Lockdown & block',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FocusModeView(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildHeroModeCard(
                            context,
                            icon: Icons.menu_book_outlined,
                            label: 'Preparation',
                            subtitle: 'Study & materials',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PreparationModeView(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const AppText.title('Daily Insight'),
                    const SizedBox(height: 8),

                    // Daily Tip Card
                    AppSection(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Productivity Tip of the Day',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.lightBlueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentTip,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const AppText.title('Quick Presets'),
                    const SizedBox(height: 8),

                    // Quick Session Presets to fill lower screen nicely
                    AppSection(
                      child: Column(
                        children: [
                          _buildPresetTile(
                            context,
                            'Quick Pomodoro',
                            '25 mins focus • 5 min break',
                            Icons.timer_outlined,
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _buildPresetTile(
                            context,
                            'Deep Work Session',
                            '45 mins strict lockdown',
                            Icons.lock_outline,
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _buildPresetTile(
                            context,
                            'Marathon Block',
                            '60 mins uninterrupted study',
                            Icons.bolt_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroModeCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          color: Colors.white.withValues(alpha: 0.02),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.lightBlueAccent),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.white38,
      ),
      onTap: () {
        // TODO: Quick launch specific timer duration
      },
    );
  }
}
