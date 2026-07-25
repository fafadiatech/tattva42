import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: Tattva42App()));
}

class Tattva42App extends StatelessWidget {
  const Tattva42App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'tattva42',
      theme: buildAppTheme(dark: false),
      darkTheme: buildAppTheme(dark: true),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
