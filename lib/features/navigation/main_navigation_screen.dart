/// 하단 네비게이션을 통해 주요 화면 전환을 관리하는 screen.
import 'package:flutter/material.dart';
import 'package:nihongo/core/constants/app_colors.dart';
import 'package:nihongo/features/learning/presentation/screens/learning_screen.dart';
import 'package:nihongo/features/vocabulary/presentation/screens/vocabulary_screen.dart';
import 'package:nihongo/features/community/presentation/screens/community_screen.dart';
import 'package:nihongo/features/community/presentation/screens/community_write_screen.dart';
import 'package:nihongo/features/stats/presentation/screens/stats_screen.dart';
import 'package:nihongo/features/my_page/presentation/screens/my_page_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _page = <Widget>[
    LearningScreen(),
    VocabularyScreen(),
    CommunityScreen(),
    StatsScreen(),
    MyPageScreen(),
  ];

  static const List<String> _appBarTitles = <String>[
    '학습',
    '단어장',
    '커뮤니티',
    '통계',
    '마이페이지',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _page,
      ),
      floatingActionButton: _selectedIndex == 2
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
          elevation: 0, // 기본 그림자 제거 (겹침 방지)
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