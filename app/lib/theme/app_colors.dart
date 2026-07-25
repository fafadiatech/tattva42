import 'package:flutter/material.dart';

/// Brand-level color tokens. Registered as a [ThemeExtension] so the entire
/// palette can be swapped at the [ThemeData] level — the only change needed
/// to white-label the app.
///
/// Access at call-site:
/// ```dart
/// final appColors = Theme.of(context).extension<AppColors>()!;
/// ```
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    this.seed = const Color(0xFF2563EB),
    this.figureAccent = const Color(0xFFF9C784),
  });

  /// Primary brand seed — drives the entire Material 3 color scheme.
  /// Swap this one color to re-theme the whole app.
  final Color seed;

  /// Accent used exclusively for "figure" extraction type.
  /// No direct M3 role maps to this semantic, so it lives here.
  final Color figureAccent;

  @override
  AppColors copyWith({Color? seed, Color? figureAccent}) => AppColors(
        seed: seed ?? this.seed,
        figureAccent: figureAccent ?? this.figureAccent,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      seed: Color.lerp(seed, other.seed, t)!,
      figureAccent: Color.lerp(figureAccent, other.figureAccent, t)!,
    );
  }
}
