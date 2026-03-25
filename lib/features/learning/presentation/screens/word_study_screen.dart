// ============================================================
// 단어 학습 화면 - Firestore에서 레벨별 단어를 불러와 플래시카드로 표시
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/presentation/providers/learning_provider.dart';
import 'package:nihongo/features/learning/presentation/widgets/word_card.dart';

class WordStudyScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const WordStudyScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  ConsumerState<WordStudyScreen> createState() => _WordStudyScreenState();
}

class _WordStudyScreenState extends ConsumerState<WordStudyScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final asyncWords = ref.watch(wordListProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: asyncWords.when(
          loading: () => Column(
            children: [
              _TopBar(title: widget.categoryTitle),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (e, _) => Column(
            children: [
              _TopBar(title: widget.categoryTitle),
              Expanded(
                child: Center(
                  child: Text(
                    '단어를 불러오지 못했어요\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          data: (words) {
            if (words.isEmpty) {
              return Column(
                children: [
                  _TopBar(title: widget.categoryTitle),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '단어가 없습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              );
            }

            final safeIndex = _currentIndex.clamp(0, words.length - 1);
            final word = words[safeIndex];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(title: widget.categoryTitle),

                const SizedBox(height: 16),

                // 통계 뱃지 (전체 / 아는 단어 / 모르는 단어)
                // TODO [통계 연결 시]: 실제 카운트로 교체
                Center(
                  child: _StatsBadgeRow(total: words.length),
                ),

                const SizedBox(height: 40),

                // 단어 카드
                Expanded(
                  child: Align(
                    alignment: const Alignment(0, -0.7),
                    child: WordCard(word: word),
                  ),
                ),

                const SizedBox(height: 24),

                // 몰라요 / 알아요 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: '몰라요',
                          color: const Color(0xFFE64A19),
                          // TODO [통계 연결 시]: unknownCount +1 업데이트 후 다음 단어로
                          onTap: () {
                            if (safeIndex < words.length - 1) {
                              setState(() => _currentIndex = safeIndex + 1);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: '알아요',
                          color: const Color(0xFF1976D2),
                          // TODO [통계 연결 시]: knownCount +1 업데이트 후 다음 단어로
                          onTap: () {
                            if (safeIndex < words.length - 1) {
                              setState(() => _currentIndex = safeIndex + 1);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 이전 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(
                        flex: 2,
                        child: _ActionButton(
                          label: '이전',
                          color: Colors.grey.shade300,
                          textColor: Colors.grey.shade600,
                          onTap: () {
                            if (safeIndex > 0) {
                              setState(() => _currentIndex = safeIndex - 1);
                            }
                          },
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// 상단 뒤로가기 + 제목
// ============================================================
class _TopBar extends StatelessWidget {
  final String title;

  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 통계 뱃지 (전체 / 아는 단어 / 모르는 단어)
// ============================================================
class _StatsBadgeRow extends StatelessWidget {
  final int total;

  const _StatsBadgeRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 전체 단어 수
          _StatBadge(
            icon: Icons.add_circle,
            color: const Color(0xFFFFC107),
            count: total,
          ),
          const SizedBox(width: 16),
          // TODO [통계 연결 시]: knownCount 값으로 교체
          const _StatBadge(
            icon: Icons.check_circle,
            color: Color(0xFF4CAF50),
            count: 0,
          ),
          const SizedBox(width: 16),
          // TODO [통계 연결 시]: unknownCount 값으로 교체
          const _StatBadge(
            icon: Icons.remove_circle,
            color: Color(0xFFF44336),
            count: 0,
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;

  const _StatBadge({
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Color textColor;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
