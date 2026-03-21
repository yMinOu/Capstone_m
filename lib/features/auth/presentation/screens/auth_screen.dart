/// Google 로그인 버튼을 제공하는 인증 화면.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/core/constants/app_colors.dart';
import 'package:nihongo/features/auth/presentation/providers/auth_provider.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authActionState = ref.watch(authActionProvider);

    ref.listen<AuthActionState>(authActionProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(authActionProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(flex: 3),
            const Text(
              '일본어, nihongo와\n함께 시작해볼까요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.headline,
                height: 1.4,
              ),
            ),
            const Spacer(flex: 2),
            authActionState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton.icon(
              onPressed: () async {
                await ref
                    .read(authActionProvider.notifier)
                    .signInWithGoogle();
              },
              icon: const Icon(Icons.login),
              label: const Text(
                'Google 계정으로 로그인',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}