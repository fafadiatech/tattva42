import 'package:flutter/material.dart';

import '../models/extraction.dart';
import '../theme/app_text_styles.dart';

/// Full-width card for a single extraction. All cards share the same surface
/// and accent color regardless of kind — the icon and label communicate type,
/// not the color.
class ExtractionChip extends StatelessWidget {
  final Extraction extraction;
  final VoidCallback? onAccept;
  final VoidCallback? onDismiss;

  const ExtractionChip({
    super.key,
    required this.extraction,
    this.onAccept,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isPending = extraction.status == ExtractionStatus.pending;
    final isDismissed = extraction.status == ExtractionStatus.dismissed;

    return Opacity(
      opacity: isDismissed ? 0.45 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(_iconFor(extraction.kind), size: 16, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kindLabel(extraction.kind),
                      style: AppTextStyles.kindBadge.copyWith(color: cs.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      extraction.text,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface,
                        decoration: isDismissed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (extraction.dueHint != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        extraction.dueHint!,
                        style: tt.labelSmall?.copyWith(color: cs.outline),
                      ),
                    ],
                  ],
                ),
              ),
              if (isPending && (onAccept != null || onDismiss != null)) ...[
                const SizedBox(width: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onAccept != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.check_circle_outline, size: 20, color: cs.primary),
                        onPressed: onAccept,
                        tooltip: 'Accept',
                      ),
                    if (onDismiss != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.cancel_outlined, size: 20, color: cs.outline),
                        onPressed: onDismiss,
                        tooltip: 'Dismiss',
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(ExtractionKind kind) {
    switch (kind) {
      case ExtractionKind.commitment:
        return Icons.task_alt_outlined;
      case ExtractionKind.decision:
        return Icons.gavel_outlined;
      case ExtractionKind.question:
        return Icons.help_outline;
      case ExtractionKind.figure:
        return Icons.bar_chart_outlined;
    }
  }

  String _kindLabel(ExtractionKind kind) {
    switch (kind) {
      case ExtractionKind.commitment:
        return 'Commitment';
      case ExtractionKind.decision:
        return 'Decision';
      case ExtractionKind.question:
        return 'Question';
      case ExtractionKind.figure:
        return 'Figure';
    }
  }
}
