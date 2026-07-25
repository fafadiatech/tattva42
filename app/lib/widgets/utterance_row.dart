import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../models/utterance.dart';
import '../theme/app_text_styles.dart';

class UtteranceRow extends StatelessWidget {
  final Utterance utterance;
  final bool isActive;
  final VoidCallback? onTap;

  const UtteranceRow({
    super.key,
    required this.utterance,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final lowConf = utterance.confidence != null && utterance.confidence! < 0.6;

    final person = mockPeople.where((p) => p.id == utterance.speakerId).firstOrNull;
    final name = person?.name ?? utterance.speakerId;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isActive ? cs.primaryContainer.withAlpha(80) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            _SpeakerAvatar(name: name, color: person?.avatarColor ?? cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: tt.labelSmall?.merge(AppTextStyles.sectionHeading)
                            .copyWith(color: cs.onSurface),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatOffset(utterance.offset),
                        style: AppTextStyles.tabularTime.copyWith(color: cs.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Opacity(
                    opacity: lowConf ? 0.5 : 1.0,
                    child: Text(
                      utterance.text,
                      style: tt.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOffset(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _SpeakerAvatar extends StatelessWidget {
  final String name;
  final Color color;
  const _SpeakerAvatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: color.withAlpha(40),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTextStyles.avatarSmall.copyWith(color: color),
      ),
    );
  }
}
