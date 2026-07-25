import 'package:flutter/material.dart';

/// Named text-style dimension tokens.
///
/// These constants define *structure only* — size, weight, spacing, font
/// features. Never hardcode a color here; apply color at the call-site with
/// `.copyWith(color: ...)` so styles stay theme-agnostic and dark-mode-safe.
///
/// Usage:
/// ```dart
/// Text('Today', style: AppTextStyles.appBarTitle)
/// Text('Sessions', style: AppTextStyles.sectionHeading.copyWith(color: cs.onSurfaceVariant))
/// ```
///
/// To white-label: adjust the constants in this file. Because every widget
/// reads from here, a single edit propagates everywhere.
abstract final class AppTextStyles {
  // ── Headings ─────────────────────────────────────────────────────────────

  /// AppBar and top-level screen title weight.
  static const TextStyle appBarTitle = TextStyle(fontWeight: FontWeight.w700);

  /// Section heading inside scrollable content (e.g. "Sessions", "Sources").
  static const TextStyle sectionHeading = TextStyle(fontWeight: FontWeight.w600);

  /// Section caption — a slightly larger variant of sectionHeading used for
  /// named section titles ("Needs attention", "Sessions", "Sources", etc.).
  /// Sits at titleMedium scale so it reads clearly above card lists.
  static const TextStyle sectionCaption = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// Bottom-sheet / modal title.
  static const TextStyle sheetTitle = TextStyle(fontWeight: FontWeight.w600);

  // ── Labels & badges ──────────────────────────────────────────────────────

  /// Extraction kind badge (Commitment, Decision, Figure…).
  /// Same size as modeChip so both category labels read at the same scale.
  static const TextStyle kindBadge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Mode chip beside session titles (Meeting, Ambient, Dictation).
  static const TextStyle modeChip = TextStyle(fontSize: 13);

  /// Small metadata: due hints, file paths, secondary descriptors.
  static const TextStyle metaLabel = TextStyle(fontSize: 14);

  /// Inline status label in the capture bar and action buttons.
  static const TextStyle statusLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  // ── Time displays ─────────────────────────────────────────────────────────

  /// Playback / offset timestamps — tabular figures keep digits fixed-width.
  static const TextStyle tabularTime = TextStyle(
    fontSize: 13,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Live-capture elapsed timer — slightly heavier than statusLabel.
  static const TextStyle captureTimer = TextStyle(
    fontSize: 15,
    fontVariations: [FontVariation('wght', 600)],
  );

  // ── Avatar initials ───────────────────────────────────────────────────────

  /// Avatar initials in list rows and utterance speakers.
  static const TextStyle avatarSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Avatar initials on profile / You screen.
  static const TextStyle avatarMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  /// Avatar initials on full person-page header.
  static const TextStyle avatarLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );
}
