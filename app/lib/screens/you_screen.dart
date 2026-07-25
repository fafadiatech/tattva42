import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../mock/mock_data.dart';
import '../providers/sessions_provider.dart';
import '../theme/app_text_styles.dart';

class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final me = mockPeople.first; // p_sidharth

    final totalSessions = sessionsAsync.maybeWhen(data: (l) => l.length, orElse: () => 0);
    final totalMinutes = sessionsAsync.maybeWhen(
      data: (l) => l.fold(0, (acc, s) => acc + s.duration.inMinutes),
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('You', style: AppTextStyles.appBarTitle),
      ),
      body: ListView(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: me.avatarColor.withAlpha(40),
                  child: Text(
                    me.name[0],
                    style: AppTextStyles.avatarMedium.copyWith(color: me.avatarColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(me.name,
                          style: tt.titleMedium?.merge(AppTextStyles.appBarTitle)),
                      if (me.role != null)
                        Text(
                          '${me.role}${me.org != null ? " · ${me.org}" : ""}',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _StatCard(label: 'Sessions', value: '$totalSessions')),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Minutes captured', value: '$totalMinutes')),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'People', value: '${mockPeople.length}')),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Settings / nav
          _SettingsTile(
            icon: Icons.shield_outlined,
            title: 'Privacy centre',
            onTap: () => context.go('/you/privacy'),
          ),
          _SettingsTile(
            icon: Icons.storage_outlined,
            title: 'Storage & files',
            onTap: () => _showStorageInfo(context),
          ),
          _SettingsTile(
            icon: Icons.bug_report_outlined,
            title: 'Audio spike test',
            subtitle: 'Developer tool — record & play test',
            onTap: () => context.go('/spike'),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About tattva42',
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Storage & files'),
        content: const Text(
          'Audio files are stored in the application documents directory.\n\n'
          'iOS: Files app > On My iPhone > tattva42\n'
          'Android: /data/data/com.fafadiatech.tattva42/files/',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'tattva42',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Fafadia Tech',
      children: [
        const SizedBox(height: 8),
        const Text('A second brain prototype for capturing and searching conversations.'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: tt.titleLarge?.merge(AppTextStyles.appBarTitle)
                  .copyWith(color: cs.primary)),
          Text(label,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
