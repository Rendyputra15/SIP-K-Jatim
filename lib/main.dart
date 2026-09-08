import 'package:flutter/material.dart';
import 'package:simodis_jatim/screens/login_screen.dart';

void main() {
  runApp(const SimodisJatimApp());
}

class SimodisJatimApp extends StatelessWidget {
  const SimodisJatimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIP-K',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
