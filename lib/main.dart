/// 앱 시작점에서 Firebase 초기화와 루트 앱 실행을 담당하는 파일.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/core/theme/app_theme.dart';
import 'package:nihongo/features/auth/presentation/widgets/auth_gate.dart';
import 'package:nihongo/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: NihongoApp(),
    ),
  );
}

class NihongoApp extends StatelessWidget {
  const NihongoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihongo App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}