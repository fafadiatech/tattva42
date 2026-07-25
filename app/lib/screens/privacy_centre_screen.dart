import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class PrivacyCentreScreen extends StatelessWidget {
  const PrivacyCentreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy centre')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            icon: Icons.mic_outlined,
            title: 'Microphone access',
            body: 'Tattva records audio only while you are actively recording. '
                'Recordings are stored locally on your device and are never uploaded.',
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Icons.record_voice_over_outlined,
            title: 'On-device transcription',
            body: 'Speech-to-text runs entirely on your device using the built-in '
                'recognition engine. No audio is sent to any server.',
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Icons.lock_outline,
            title: 'Private sessions',
            body: 'Sessions marked as private are never included in search results '
                'or shared with other users.',
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Icons.delete_forever_outlined,
            title: 'Deleting your data',
            body: 'You can delete individual sessions and their audio files from the '
                'session detail screen. Deleting the app removes all stored data.',
          ),
          const SizedBox(height: 24),
          Text(
            'Questions? Contact privacy@fafadiatech.com',
            style: tt.bodySmall?.copyWith(color: cs.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Section({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: cs.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.sectionCaption),
                  const SizedBox(height: 4),
                  Text(body, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
