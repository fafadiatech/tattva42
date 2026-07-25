import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the app-wide [ThemeMode].
/// Defaults to [ThemeMode.system] so new installs respect OS preference.
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);
