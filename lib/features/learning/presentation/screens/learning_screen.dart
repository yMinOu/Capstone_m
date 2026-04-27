// ============================================================
// 학습 화면 - 이미지 버튼 로드맵 구성
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/presentation/providers/learning_provider.dart';
import 'package:nihongo/features/learning/presentation/screens/character_study_screen.dart';
import 'package:nihongo/features/learning/presentation/screens/kanji_study_screen.dart';
import 'package:nihongo/features/learning/presentation/screens/sentence_study_screen.dart';
import 'package:nihongo/features/learning/presentation/screens/word_study_screen.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_content_model.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({
    super.key,
    required this.animationSeed,
  });

  final int animationSeed;

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen>
    with TickerProviderStateMixin {
  late AnimationController _itemAnimationController;
  late Animation<Offset> _itemSlideAnimation;

  late AnimationController _bottomItemAnimationController;
  late Animation<Offset> _item2SlideAnimation;
  late Animation<Offset> _item3SlideAnimation;

  late AnimationController _lineAnimationController;
  late AnimationController _miniItemAnimationController;

  @override
  void initState() {
    super.initState();

    _itemAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _itemSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _itemAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _bottomItemAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _item2SlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _bottomItemAnimationController,
        curve: const Interval(
          0.0,
          0.65,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _item3SlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _bottomItemAnimationController,
        curve: const Interval(
          0.35,
          1.0,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _miniItemAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _itemAnimationController.forward();
    _bottomItemAnimationController.forward();
    _lineAnimationController.forward();
    _miniItemAnimationController.forward();
  }

  @override
  void didUpdateWidget(covariant LearningScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationSeed != widget.animationSeed) {
      _itemAnimationController.forward(from: 0);
      _bottomItemAnimationController.forward(from: 0);
      _lineAnimationController.forward(from: 0);
      _miniItemAnimationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _itemAnimationController.dispose();
    _bottomItemAnimationController.dispose();
    _lineAnimationController.dispose();
    _miniItemAnimationController.dispose();
    _miniItemAnimationController.dispose();
    super.dispose();
  }

  void _goToCharacterSelect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _CharacterSelectScreen(),
      ),
    );
  }

  void _goToWordSelect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _CategorySelectScreen(
          title: '단어',
          type: _StudyCategoryType.word,
        ),
      ),
    );
  }

  void _goToKanjiSelect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _CategorySelectScreen(
          title: '한자',
          type: _StudyCategoryType.kanji,
        ),
      ),
    );
  }

  void _goToSentenceSelect() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _CategorySelectScreen(
          title: '예문',
          type: _StudyCategoryType.sentence,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/study/study_bg2.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            _MiniStudyItems(animation: _miniItemAnimationController),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        '학습',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 70),

                    SizedBox(
                      height: 620,
                      child: AnimatedBuilder(
                        animation: _lineAnimationController,
                        builder: (context, _) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _DottedRoadPainter(
                                    progress: _lineAnimationController.value,
                                  ),
                                ),
                              ),

                              _RoadMapButton(
                                top: 20,
                                left: 40,
                                imagePath: 'assets/study/btn1.png',
                                onTap: _goToCharacterSelect,
                              ),

                              _RoadMapButton(
                                top: 130,
                                right: 40,
                                imagePath: 'assets/study/btn2.png',
                                onTap: _goToWordSelect,
                              ),

                              _RoadMapButton(
                                top: 240,
                                left: 40,
                                imagePath: 'assets/study/btn3.png',
                                onTap: _goToKanjiSelect,
                              ),

                              _RoadMapButton(
                                top: 350,
                                right: 40,
                                imagePath: 'assets/study/btn4.png',
                                onTap: _goToSentenceSelect,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            IgnorePointer(
              child: SlideTransition(
                position: _itemSlideAnimation,
                child: const _TopStudyItemImage(),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Stack(
                  children: [
                    SlideTransition(
                      position: _item2SlideAnimation,
                      child: Transform.translate(
                        offset: const Offset(0, 40),
                        child: Image.asset(
                          'assets/study/study_item2.png',
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),

                    SlideTransition(
                      position: _item3SlideAnimation,
                      child: Image.asset(
                        'assets/study/study_item3.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 상단 이미지
// ============================================================
class _TopStudyItemImage extends StatelessWidget {
  const _TopStudyItemImage();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Image.asset(
        'assets/study/study_item.png',
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}


// ============================================================
// 지그재그 버튼
// ============================================================
class _RoadMapButton extends StatelessWidget {
  final double top;
  final double? left;
  final double? right;
  final String imagePath;
  final VoidCallback onTap;

  const _RoadMapButton({
    required this.top,
    this.left,
    this.right,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: onTap,
        child: Image.asset(
          imagePath,
          width: MediaQuery.of(context).size.width * 0.23,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ============================================================
// 점선 연결 애니메이션
// ============================================================
class _DottedRoadPainter extends CustomPainter {
  final double progress;

  _DottedRoadPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF9F9F).withOpacity(0.75)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = <Offset>[
      Offset(size.width * 0.24, 65),
      Offset(size.width * 0.76, 175),
      Offset(size.width * 0.24, 285),
      Offset(size.width * 0.76, 395),
    ];

    final path = Path()..moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final current = points[i];

      path.cubicTo(
        prev.dx,
        prev.dy + 80,
        current.dx,
        current.dy - 80,
        current.dx,
        current.dy,
      );
    }

    final metrics = path.computeMetrics().toList();
    for (final metric in metrics) {
      final drawLength = metric.length * progress;
      final partialPath = metric.extractPath(0, drawLength);

      for (final m in partialPath.computeMetrics()) {
        double distance = 0;

        while (distance < m.length) {
          final next = (distance + 10).clamp(0, m.length).toDouble();
          canvas.drawPath(
            m.extractPath(distance, next),
            paint,
          );
          distance += 22;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedRoadPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ============================================================
// 문자 선택 화면
// ============================================================
class _CharacterSelectScreen extends StatelessWidget {
  const _CharacterSelectScreen();

  @override
  Widget build(BuildContext context) {
    return _StudySelectScaffold(
      title: '문자',
      child: ListView(
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
      ),
    );
  }
}

// ============================================================
// 단어 / 한자 / 예문 선택 화면
// ============================================================
enum _StudyCategoryType {
  word,
  kanji,
  sentence,
}

class _CategorySelectScreen extends ConsumerWidget {
  final String title;
  final _StudyCategoryType type;

  const _CategorySelectScreen({
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = switch (type) {
      _StudyCategoryType.word => ref.watch(wordCategoryProvider),
      _StudyCategoryType.kanji => ref.watch(kanjiCategoryProvider),
      _StudyCategoryType.sentence => ref.watch(sentenceCategoryProvider),
    };

    return _StudySelectScaffold(
      title: title,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return _CategoryCard(
            category: category,
            onTap: () {
              if (type == _StudyCategoryType.word) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordStudyScreen(
                      categoryId: category.id,
                      categoryTitle: category.title,
                    ),
                  ),
                );
              } else if (type == _StudyCategoryType.kanji) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KanjiStudyScreen(
                      categoryId: category.id,
                      categoryTitle: category.title,
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SentenceStudyScreen(
                      categoryId: category.id,
                      categoryTitle: category.title,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// 선택 화면 공통 스캐폴드
// ============================================================
class _StudySelectScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const _StudySelectScaffold({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 카드 공통
// ============================================================
class _SimpleCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SimpleCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: title,
      onTap: onTap,
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final WordCategory category;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: category.title,
      onTap: onTap,
    );
  }
}

class _BaseCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _BaseCard({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFCCCC),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.menu_book_outlined,
                color: Color(0xFFD37B7B),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStudyItems extends StatelessWidget {
  final Animation<double> animation;

  const _MiniStudyItems({required this.animation});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Stack(
            children: [
              _mini('assets/study/miniItem1.png', 120, left: 20, v: animation.value, s: 0.0),
              _mini('assets/study/miniItem2.png', 170, right: 30, v: animation.value, s: 0.1),
              _mini('assets/study/miniItem3.png', 230, right: 120, v: animation.value, s: 0.2),
              _mini('assets/study/miniItem4.png', 330, left: 80, v: animation.value, s: 0.3),
              _mini('assets/study/miniItem5.png', 550, left: 30, v: animation.value, s: 0.4),
              _mini('assets/study/miniItem6.png', 450, right: 30, v: animation.value, s: 0.5),
            ],
          );
        },
      ),
    );
  }

  Widget _mini(String path, double top,
      {double? left, double? right, required double v, required double s}) {
    final p = ((v - s) / 0.4).clamp(0.0, 1.0);
    final scale = 0.3 + (0.7 * Curves.easeOutBack.transform(p));

    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Opacity(
        opacity: p,
        child: Transform.scale(
          scale: scale,
          child: Image.asset(path, width: 32),
        ),
      ),
    );
  }
}