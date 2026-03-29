import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/auth/presentation/providers/auth_provider.dart';
import 'package:nihongo/features/my_page/presentation/providers/my_page_provider.dart';
import 'package:nihongo/features/my_page/presentation/widgets/my_page_dialogs.dart';
import 'package:nihongo/features/my_page/presentation/widgets/my_page_menu_tile.dart';
import 'package:nihongo/features/my_page/presentation/widgets/my_page_profile_section.dart';
import 'package:nihongo/core/constants/app_colors.dart';

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
                children: [
                  const SizedBox(height: 28),
                  MyPageProfileSection(user: user),
                  const SizedBox(height: 28),

                  const _SectionTitle('계정'),
                  const SizedBox(height: 5),

                  MyPageMenuTile(
                    title: '이메일',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/common/google_logo.png',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.email!,
                          style: const TextStyle(color: AppColors.textGrey),
                        ),
                      ],
                    ),
                    onTap: null,
                  ),
                  Divider(height: 0, thickness: 0.5,),
                  MyPageMenuTile(
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
                  Divider(height: 0, thickness: 0.5,),

                  MyPageMenuTile(
                    title: '계정 탈퇴',
                    onTap: () async {
                      final confirmed = await showMyPageConfirmationDialog(
                        context,
                        title: '계정 탈퇴',
                        content: '정말 탈퇴하시겠습니까?',
                        confirmText: '탈퇴',
                      );
                      if (confirmed == true) {
                        await ref
                            .read(myPageActionProvider.notifier)
                            .deleteAccount(user);
                      }
                    },
                  ),
                  Divider(height: 0, thickness: 0.5,),

                  const SizedBox(height: 12),

                  const _SectionTitle('고객지원'),
                  const SizedBox(height: 5),
                  
                  MyPageMenuTile(
                    title: '공지사항',
                    onTap: (){},
                  ),
                  Divider(height: 0, thickness: 0.5,),
                  MyPageMenuTile(
                    title: '의견 남기기',
                    onTap: (){},
                  ),
                  Divider(height: 0, thickness: 0.5,),

                  const SizedBox(height: 12),
                  
                  const _SectionTitle('설정'),
                  const SizedBox(height: 5),

                  MyPageMenuTile(
                    title: '현재 버전',
                    trailing: const Text(
                      'v1.0.0',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                    onTap: null,
                  ),
                  Divider(height: 0, thickness: 0.5,),

                  MyPageMenuTile(
                    title: '이용약관',
                    onTap: (){},
                  ),
                  Divider(height: 0, thickness: 0.5,),

                  MyPageMenuTile(
                    title: '개인정보 처리방침',
                    onTap: (){},
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
        error: (e, stack) => Center(child: Text('오류: $e')),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textBlack,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
    );
  }
}