// ============================================================
// 학습 화면 - 단어 / 한자 / 예문 탭 구성
// ============================================================
// 현재 구현 상태:
//   - 단어 탭: Firestore 연동 완료
//   - 한자 탭: 미구현 (준비 중 표시)
//   - 예문 탭: Firestore 연동 완료
//
// TODO [한자 탭 구현 시]: _ComingSoonView() → 한자 전용 위젯으로 교체
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/presentation/providers/learning_provider.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
            // 탭바 (단어 / 한자 / 예문)
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: '단어'),
                Tab(text: '한자'),
                Tab(text: '예문'),
              ],
            ),

            // 탭 내용
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  // 단어 탭 - UI 구현 완료
                  _WordTabView(),

                  // TODO [한자 탭 구현 시]: _ComingSoonView() 를 한자 위젯으로 교체
                  _ComingSoonView(),

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
// 한자 탭 - 아직 미구현
// ============================================================
// TODO [구현 시]: 이 위젯 대신 한자 위젯으로 교체
class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '준비 중입니다',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
