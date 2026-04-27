/// 하단 네비게이션을 통해 주요 화면 전환을 관리하는 screen.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/core/constants/app_colors.dart';
import 'package:nihongo/services/tts_service.dart';
import 'package:nihongo/features/learning/presentation/screens/learning_screen.dart';
import 'package:nihongo/features/vocabulary/presentation/screens/vocabulary_screen.dart';
import 'package:nihongo/features/community/presentation/screens/community_screen.dart';
import 'package:nihongo/features/community/presentation/screens/community_write_screen.dart';
import 'package:nihongo/features/community/presentation/providers/community_provider.dart';
import 'package:nihongo/features/stats/presentation/screens/stats_screen.dart';
import 'package:nihongo/features/my_page/presentation/screens/my_page_screen.dart';
import 'package:nihongo/features/vocabulary/presentation/providers/vocabulary_provider.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;
  int _statsAnimationSeed = 0;

  @override
  void initState() {
    super.initState();
    _checkTtsAvailability();
  }

  Future<void> _checkTtsAvailability() async {
    await TtsService.instance.initialize();
    if (!mounted) return;
    if (!TtsService.instance.japaneseAvailable) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('일본어 TTS 설치 필요'),
            content: const Text(
              '발음 듣기 기능을 사용하려면 일본어 TTS 언어팩이 필요합니다.\n\n'
              '설정 → 일반 관리 → 언어 및 입력 → 텍스트 음성 변환에서 일본어 언어 데이터를 설치해 주세요.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      });
    }
  }

  static const List<String> _appBarTitles = <String>[
    '학습',
    '단어장',
    '커뮤니티',
    '통계',
    '마이페이지',
  ];

  List<Widget> _buildPages() {
    return <Widget>[
      const LearningScreen(),
      const VocabularyScreen(),
      const CommunityScreen(),
      StatsScreen(
        animationSeed: _statsAnimationSeed,
        isActive: _selectedIndex == 3,
      ),
      const MyPageScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 3) {
        _statsAnimationSeed++;
      }
    });

    if (index == 1) {
      Future.microtask(() {
        ref.read(learningProgressPagingProvider.notifier).refreshOnlyNew();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityTab = ref.watch(communityTabProvider);
    final pages = _buildPages();

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: _selectedIndex == 3
            ? const Color(0xFFFFF3F6)
            : Colors.white,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      floatingActionButton: (_selectedIndex == 2)
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunityWriteScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.edit),
      )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_outlined),
              activeIcon: Icon(Icons.edit),
              label: '학습',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: '단어장',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.textsms_outlined),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: '통계',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '마이페이지',
            ),
          ],
        ),
      ),
    );
  }
}