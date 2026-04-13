// ============================================================
// 예문 학습 화면 - Firestore에서 레벨별 예문을 불러와 카드로 표시
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/presentation/providers/learning_provider.dart';
import 'package:nihongo/widgets/sentence_card.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_content_model.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/vocabulary_select_bottom_sheet.dart';

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

  void _maybeLoadMore(int currentIndex, int totalLoaded) {
    if (currentIndex >= totalLoaded - 10) {
      ref.read(paginatedSentenceProvider(widget.categoryId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageState = ref.watch(paginatedSentenceProvider(widget.categoryId));

    Widget body;

    if (pageState.isInitialLoading) {
      body = Column(
        children: [
          _TopBar(title: widget.categoryTitle),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    } else if (pageState.error != null && pageState.words.isEmpty) {
      body = Column(
        children: [
          _TopBar(title: widget.categoryTitle),
          Expanded(
            child: Center(
              child: Text(
                '예문을 불러오지 못했어요\n${pageState.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    } else if (pageState.words.isEmpty) {
      body = Column(
        children: [
          _TopBar(title: widget.categoryTitle),
          const Expanded(
            child: Center(
              child: Text('예문이 없습니다', style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      );
    } else {
      final sentences = pageState.words;
      final safeIndex = _currentIndex.clamp(0, sentences.length - 1);
      final sentence = sentences[safeIndex];

      Future.microtask(() => _maybeLoadMore(safeIndex, sentences.length));

      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(title: widget.categoryTitle),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '${safeIndex + 1} / ${pageState.totalCount > 0 ? pageState.totalCount : sentences.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SentenceCard(
            sentence: sentence,
            onTapVocabularySave: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => VocabularySelectBottomSheet(
                  content: LearningContentModel(
                    id: sentence.id,
                    category: sentence.category,
                    subCategory: sentence.subCategory,
                    contentType: sentence.contentType,
                    content: sentence.content,
                    meaning: sentence.meaning,
                    sourceId: '',
                    isActive: true,
                    createdAt: null,
                    updatedAt: null,
                    furigana: sentence.furigana,
                    romaji: sentence.romaji,
                    onReading: '',
                    kunReading: '',
                    pronunciationKr: sentence.pronunciationKr,
                    order: null,
                    examples: sentence.examples
                        .map(
                          (example) => LearningContentExampleModel(
                            content: example.content,
                            furigana: null,
                            meaning: example.meaning,
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
            onPrevious: safeIndex > 0
                ? () => setState(() => _currentIndex = safeIndex - 1)
                : null,
            onNext: safeIndex < sentences.length - 1
                ? () => setState(() => _currentIndex = safeIndex + 1)
                : null,
          ),
          if (pageState.isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: body),
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
