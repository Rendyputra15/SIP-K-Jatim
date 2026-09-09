import 'package:flutter/material.dart';
import 'package:simodis_jatim/screens/login_screen.dart';
import 'package:simodis_jatim/services/theme_service.dart';

void main() {
  runApp(const SimodisJatimApp());
}

class SimodisJatimApp extends StatelessWidget {
  const SimodisJatimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'SIP-K',
          debugShowCheckedModeBanner: false,
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: currentMode,
          home: const LoginScreen(),
        );
      },
    );
  }
}

