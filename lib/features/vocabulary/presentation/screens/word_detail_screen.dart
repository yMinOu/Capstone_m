import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart' as ui;
import 'package:nihongo/widgets/character_card.dart';
import 'package:nihongo/widgets/kanji_card.dart';
import 'package:nihongo/widgets/sentence_card.dart';
import 'package:nihongo/widgets/word_card.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_content_model.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_progress_model.dart';
import 'package:nihongo/features/vocabulary/presentation/providers/vocabulary_provider.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/vocabulary_select_bottom_sheet.dart';

class MyWordDetailScreen extends ConsumerWidget {
  const MyWordDetailScreen({
    super.key,
    required this.progress,
  });

  final LearningProgressModel progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(learningContentDetailProvider(progress.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(progress.content),
      ),
      body: contentAsync.when(
        data: (content) {
          final uiModel = _convertToUIModel(content);
          final screenHeight = MediaQuery.of(context).size.height;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              0,
              screenHeight * 0.15,
              0,
              40,
            ),
            child: _buildCard(
              context: context,
              content: content,
              model: uiModel,
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, _) => Center(
          child: Text('상세 데이터를 불러올 수 없습니다.\n$err'),
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required LearningContentModel content,
    required ui.WordModel model,
  }) {
    final onTapSaveVocabulary = () {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => VocabularySelectBottomSheet(content: content),
      );
    };

    switch (content.contentType) {
      case 'character':
        return CharacterCard(
          character: model,
          initialFlipped: false,
          onUnknown: () {},
          onKnown: () {},
          onTapVocabularySave: onTapSaveVocabulary,
        );
      case 'kanji':
        return KanjiCard(
          word: model,
          initialFlipped: true,
          onTapVocabularySave: onTapSaveVocabulary,
        );
      case 'sentence':
        return SentenceCard(
          sentence: model,
          onTapVocabularySave: onTapSaveVocabulary,
        );
      case 'word':
      default:
        return WordCard(
          word: model,
          initialFlipped: true,
          onTapVocabularySave: onTapSaveVocabulary,
        );
    }
  }

  ui.WordModel _convertToUIModel(LearningContentModel content) {
    return ui.WordModel(
      id: content.id,
      category: content.category,
      subCategory: content.subCategory,
      contentType: content.contentType,
      content: content.content,
      meaning: content.meaning,
      isActive: content.isActive,
      furigana: content.furigana,
      romaji: content.romaji,
      pronunciationKr: content.pronunciationKr,
      examples: content.examples
          .map(
            (example) => ui.WordExample(
          content: example.content,
          meaning: example.meaning,
        ),
      )
          .toList(),
    );
  }
}