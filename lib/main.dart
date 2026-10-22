import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AasmanAlertApp());
}

class AasmanAlertApp extends StatelessWidget {
  const AasmanAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'آسمان الرٹ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF124A8A),
          primary: const Color(0xFF124A8A),
          secondary: const Color(0xFF159B68),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const HomeScreen(),
    );
  }
}
