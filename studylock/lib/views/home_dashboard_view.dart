import 'package:flutter/material.dart';
import 'package:studylock/components/app_section.dart';
import 'package:studylock/components/app_text.dart';
import 'package:studylock/views/preparation_mode_view.dart';

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const AppText.title('Welcome back!'),
                    const SizedBox(height: 8),
                    const AppText.body("Let's start the study session?"),
                    const SizedBox(height: 16),
                    AppSection(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModeCard(
                              context,
                              icon: Icons.shield_outlined,
                              label: 'Focus mode',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildModeCard(
                              context,
                              icon: Icons.menu_book_outlined,
                              label: 'Preparation mode',
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
                    ),
                    const SizedBox(height: 16),
                    const AppText.title('Recent Preparations'),
                    const SizedBox(height: 6),
                    AppSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.map,
                              color: Colors.white70,
                            ),
                            title: const Text(
                              'Map',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.photo_album,
                              color: Colors.white70,
                            ),
                            title: const Text(
                              'Album',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.phone,
                              color: Colors.white70,
                            ),
                            title: const Text(
                              'Phone',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {},
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

  Widget _buildModeCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white70),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
