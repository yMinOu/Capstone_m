// ============================================================
// 학습 화면 - 문자 / 단어 / 한자 / 예문 탭 구성
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/presentation/providers/learning_provider.dart';
import 'package:nihongo/features/learning/presentation/screens/character_study_screen.dart';
import 'package:nihongo/features/learning/presentation/screens/kanji_study_screen.dart';
import 'package:nihongo/features/learning/presentation/screens/sentence_study_screen.dart';
import 'package:nihongo/features/learning/presentation/screens/word_study_screen.dart';


class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(text: '문자'),
                Tab(text: '단어'),
                Tab(text: '한자'),
                Tab(text: '예문'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _HiraganaKatakanaTabView(),
                  _WordTabView(),
                  _KanjiTabView(),
                  _SentenceTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 히라가나/가타카나 탭 화면
// ============================================================
class _HiraganaKatakanaTabView extends StatelessWidget {
  const _HiraganaKatakanaTabView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _SimpleCard(
          title: '히라가나 학습',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CharacterStudyScreen(
                title: '히라가나',
                weakStatsLabel: '히라가나',
                characterType: 'hiragana',
              ),
            ),
          ),
        ),
        _SimpleCard(
          title: '가타카나 학습',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CharacterStudyScreen(
                title: '가타카나',
                weakStatsLabel: '가타카나',
                characterType: 'katakana',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 히라가나/가타카나용 단순 카드
// ============================================================
class _SimpleCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SimpleCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: ListTile(
            leading: Icon(Icons.menu_book_outlined, color: Colors.grey.shade500),
            title: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 단어 탭 화면
// ============================================================
class _WordTabView extends ConsumerWidget {
  const _WordTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(wordCategoryProvider);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          category: category,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WordStudyScreen(
                categoryId: category.id,
                categoryTitle: category.title,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// 단어 카테고리 카드
// ============================================================
class _CategoryCard extends StatelessWidget {
  final WordCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: ListTile(
            leading: Icon(
              Icons.menu_book_outlined,
              color: Colors.grey.shade500,
            ),
            title: Text(
              category.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 예문 탭 화면
// ============================================================
class _SentenceTabView extends ConsumerWidget {
  const _SentenceTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(sentenceCategoryProvider);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          category: category,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SentenceStudyScreen(
                categoryId: category.id,
                categoryTitle: category.title,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// 한자 탭 화면
// ============================================================
class _KanjiTabView extends ConsumerWidget {
  const _KanjiTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(kanjiCategoryProvider);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          category: category,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KanjiStudyScreen(
                categoryId: category.id,
                categoryTitle: category.title,
              ),
            ),
          ),
        );
      },
    );
  }
}
