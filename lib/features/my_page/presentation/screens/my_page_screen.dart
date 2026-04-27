import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/core/constants/app_colors.dart';
import 'package:nihongo/features/auth/presentation/providers/auth_provider.dart';
import 'package:nihongo/features/my_page/data/repositories/feedback_repository.dart';
import 'package:nihongo/features/my_page/presentation/providers/my_page_provider.dart';
import 'package:nihongo/features/my_page/presentation/screens/feedback_list_screen.dart';
import 'package:nihongo/features/my_page/presentation/screens/notice_list_screen.dart';
import 'package:nihongo/features/my_page/presentation/screens/privacy_screen.dart';
import 'package:nihongo/features/my_page/presentation/screens/terms_screen.dart';
import 'package:nihongo/features/my_page/presentation/widgets/my_page_dialogs.dart';
import 'package:nihongo/features/my_page/presentation/widgets/my_page_menu_tile.dart';
import 'package:video_player/video_player.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUserState = ref.watch(authUserProvider);
    final myPageActionState = ref.watch(myPageActionProvider);
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

    ref.listen<MyPageActionState>(myPageActionProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(myPageActionProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: authUserState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('사용자 정보를 찾을 수 없습니다.'));
          }

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 36),
                children: [
                  const SizedBox(height: 18),
                  _MyPageVideoHeader(
                    isActive: isActive,
                    displayName: user.displayName ?? '사용자',
                  ),
                  const SizedBox(height: 18),

                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle('계정'),
                          SizedBox(height: 8),
                        ],
                      ),
                      Positioned(
                        right: 28,
                        top: -26,
                        child: Image.asset(
                          'assets/images/common/mypage_flower.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  _MenuSectionCard(
                    children: [
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
                              user.email ?? '-',
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        onTap: null,
                      ),
                      const _CardDivider(),
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
                            await ref
                                .read(myPageActionProvider.notifier)
                                .logout();
                          }
                        },
                      ),
                      const _CardDivider(),
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
                    ],
                  ),

                  const SizedBox(height: 22),

                  const _SectionTitle('고객지원'),
                  const SizedBox(height: 8),
                  _MenuSectionCard(
                    children: [
                      MyPageMenuTile(
                        title: '공지사항',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NoticeListScreen(),
                          ),
                        ),
                      ),
                      const _CardDivider(),
                      MyPageMenuTile(
                        title: '의견 남기기',
                        onTap: () => showFeedbackDialog(
                          context,
                          onSubmit: (content) =>
                              FeedbackRepository().submitFeedback(
                                uid: user.uid,
                                content: content,
                              ),
                        ),
                      ),
                      if (isAdmin) ...[
                        const _CardDivider(),
                        MyPageMenuTile(
                          title: '의견 보기',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FeedbackListScreen(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 22),

                  const _SectionTitle('설정'),
                  const SizedBox(height: 8),
                  _MenuSectionCard(
                    children: [
                      MyPageMenuTile(
                        title: '현재 버전',
                        trailing: Text(
                          ref.watch(appVersionProvider).valueOrNull ?? '-',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13,
                          ),
                        ),
                        onTap: null,
                      ),
                      const _CardDivider(),
                      MyPageMenuTile(
                        title: '이용약관',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsScreen(),
                          ),
                        ),
                      ),
                      const _CardDivider(),
                      MyPageMenuTile(
                        title: '개인정보 처리방침',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyScreen(),
                          ),
                        ),
                      ),
                    ],
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

class _MyPageVideoHeader extends StatefulWidget {
  const _MyPageVideoHeader({
    required this.isActive,
    required this.displayName,
  });

  final bool isActive;
  final String displayName;

  @override
  State<_MyPageVideoHeader> createState() => _MyPageVideoHeaderState();
}

class _MyPageVideoHeaderState extends State<_MyPageVideoHeader> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/images/common/mypage_cat.mp4',
    );

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.setVolume(0);

    if (!mounted) return;

    setState(() {
      _isInitialized = true;
    });

    _syncPlayback();
  }

  @override
  void didUpdateWidget(covariant _MyPageVideoHeader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      _syncPlayback();
    }
  }

  void _syncPlayback() {
    if (!_controller.value.isInitialized) return;

    if (widget.isActive) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 100,
              height: 100,
              child: _isInitialized
                  ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
                  : const ColoredBox(
                color: Color(0xFFFFF3F6),
              ),
            ),
          ),
        ),

        Column(
          children: [
            Text(
              '안녕하세요 ${widget.displayName}님!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'こんにちは ${widget.displayName}さん！',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textBlack,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MenuSectionCard extends StatelessWidget {
  const _MenuSectionCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFCCCC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 0,
        thickness: 0.6,
        color: Color(0xFFFFE0E0),
      ),
    );
  }
}