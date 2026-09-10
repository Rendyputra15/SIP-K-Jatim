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
    // Mendengarkan perubahan themeMode
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, currentMode, _) {
        // Mendengarkan perubahan skala teks (teks lebih besar)
        return ValueListenableBuilder<double>(
          valueListenable: ThemeService.textScaleNotifier,
          builder: (context, textScale, _) {
            return MaterialApp(
              title: 'SIP-K',
              debugShowCheckedModeBanner: false,
              theme: ThemeService.lightTheme,
              darkTheme: ThemeService.darkTheme,
              themeMode: currentMode,
              home: const LoginScreen(),
              // builder menerapkan textScaleFactor ke seluruh widget tree
              // Ini adalah cara paling efektif untuk mengubah ukuran teks global
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(textScale),
                  ),
                  child: child!,
                );
              },
            );
          },
        );
      },
    );
  }
}
