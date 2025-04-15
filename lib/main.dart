// lib/main.dart

import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // .env 파일 로드
  try {
    await FirebaseService().initialize();
    print("FirebaseService 초기화 완료");
  } catch (e) {
    print("FirebaseService 초기화 오류: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkTheme = false;

  // 테마 전환 함수
  void _toggleTheme() => setState(() => isDarkTheme = !isDarkTheme);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallert',
      theme: buildAppTheme(isDark: isDarkTheme),
      home: HomeScreen(
        title: 'Wallert',
        toggleTheme: _toggleTheme,
        isDarkTheme: isDarkTheme,
      ),
    );
  }
}
