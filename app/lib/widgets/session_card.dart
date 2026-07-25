import 'package:flutter/material.dart';

import '../models/session.dart';
import '../theme/app_text_styles.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionCard({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: tt.titleSmall?.merge(AppTextStyles.sectionHeading),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ModeChip(mode: session.mode),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                session.summary,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 13, color: cs.outline),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(session.duration),
                    style: tt.labelSmall?.copyWith(color: cs.outline),
                  ),
                  if (session.location != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.place_outlined, size: 13, color: cs.outline),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session.location!,
                        style: tt.labelSmall?.copyWith(color: cs.outline),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (session.syncState == SyncState.local) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.cloud_off_outlined, size: 13, color: cs.outline),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }
}

class _ModeChip extends StatelessWidget {
  final CaptureMode mode;
  const _ModeChip({required this.mode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    String label;
    IconData icon;
    switch (mode) {
      case CaptureMode.meeting:
        label = 'Meeting';
        icon = Icons.groups_outlined;
      case CaptureMode.ambient:
        label = 'Ambient';
        icon = Icons.hearing_outlined;
      case CaptureMode.dictation:
        label = 'Dictation';
        icon = Icons.record_voice_over_outlined;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: cs.secondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.modeChip.copyWith(color: cs.secondary),
        ),
      ],
    );
  }
}
