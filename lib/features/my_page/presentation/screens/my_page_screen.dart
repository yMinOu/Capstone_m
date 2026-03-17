import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/auth/presentation/providers/auth_provider.dart';
import 'package:nihongo/features/my_page/presentation/providers/my_page_provider.dart';
import 'package:nihongo/features/my_page/presentation/widgets/my_page_dialogs.dart';
import 'package:nihongo/features/my_page/presentation/widgets/my_page_menu_tile.dart';
import 'package:nihongo/features/my_page/presentation/widgets/my_page_profile_section.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserState = ref.watch(authUserProvider);
    final myPageActionState = ref.watch(myPageActionProvider);

    ref.listen<MyPageActionState>(myPageActionProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(myPageActionProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: authUserState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('사용자 정보를 찾을 수 없습니다.'));
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  MyPageProfileSection(user: user),
                  const SizedBox(height: 32),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  MyPageMenuTile(
                    icon: Icons.logout,
                    title: '로그아웃',
                    onTap: () async {
                      final confirmed = await showMyPageConfirmationDialog(
                        context,
                        title: '로그아웃',
                        content: '정말 로그아웃 하시겠습니까?',
                        confirmText: '로그아웃',
                      );

                      if (confirmed == true) {
                        await ref.read(myPageActionProvider.notifier).logout();
                      }
                    },
                  ),
                  MyPageMenuTile(
                    icon: Icons.info_outline,
                    title: '앱 정보',
                    onTap: () => showMyPageAppInfoDialog(context),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  MyPageMenuTile(
                    icon: Icons.delete_forever,
                    title: '계정 탈퇴',
                    color: Colors.red,
                    onTap: () async {
                      final confirmed = await showMyPageConfirmationDialog(
                        context,
                        title: '계정 탈퇴',
                        content:
                        '정말 계정을 탈퇴하시겠습니까?\n이 작업은 되돌릴 수 없으며, 모든 개인 정보가 삭제됩니다.',
                        confirmText: '탈퇴',
                      );

                      if (confirmed == true) {
                        await ref.read(myPageActionProvider.notifier).deleteAccount(user);
                      }
                    },
                  ),
                ],
              ),
              if (myPageActionState.isLoading)
                const ColoredBox(
                  color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('오류가 발생했습니다: $e')),
      ),
    );
  }
}