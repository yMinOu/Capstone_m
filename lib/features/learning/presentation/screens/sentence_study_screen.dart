// ============================================================
// 예문 학습 화면 - Firestore에서 레벨별 예문을 불러와 카드로 표시
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/presentation/providers/learning_provider.dart';
import 'package:nihongo/widgets/sentence_card.dart';

class SentenceStudyScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryTitle;

  const SentenceStudyScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  ConsumerState<SentenceStudyScreen> createState() => _SentenceStudyScreenState();
}

class _SentenceStudyScreenState extends ConsumerState<SentenceStudyScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final asyncSentences = ref.watch(sentenceListProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: asyncSentences.when(
          loading: () => Column(
            children: [
              _TopBar(title: widget.categoryTitle),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
          error: (e, _) => Column(
            children: [
              _TopBar(title: widget.categoryTitle),
              Expanded(
                child: Center(
                  child: Text(
                    '예문을 불러오지 못했어요\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          data: (sentences) {
            if (sentences.isEmpty) {
              return Column(
                children: [
                  _TopBar(title: widget.categoryTitle),
                  const Expanded(
                    child: Center(
                      child: Text(
                        '예문이 없습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              );
            }

            final safeIndex = _currentIndex.clamp(0, sentences.length - 1);
            final sentence = sentences[safeIndex];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(title: widget.categoryTitle),

                const SizedBox(height: 16),

                // 진행도 표시
                Center(
                  child: Text(
                    '${safeIndex + 1} / ${sentences.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 예문 카드 (버튼 포함)
                SentenceCard(
                  sentence: sentence,
                  onPrevious: safeIndex > 0
                      ? () => setState(() => _currentIndex = safeIndex - 1)
                      : null,
                  onNext: safeIndex < sentences.length - 1
                      ? () => setState(() => _currentIndex = safeIndex + 1)
                      : null,
                ),

                const SizedBox(height: 24),
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

