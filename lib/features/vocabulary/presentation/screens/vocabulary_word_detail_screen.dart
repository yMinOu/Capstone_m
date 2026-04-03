import 'package:flutter/material.dart';
import 'package:nihongo/features/vocabulary/data/models/word_model.dart';
import 'package:nihongo/widgets/character_card.dart';
import 'package:nihongo/widgets/kanji_card.dart';
import 'package:nihongo/widgets/sentence_card.dart';
import 'package:nihongo/widgets/word_card.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart' as ui;
import 'package:nihongo/features/vocabulary/data/models/learning_content_model.dart';
import 'package:nihongo/features/vocabulary/presentation/widgets/vocabulary_select_bottom_sheet.dart';

class VocabularyWordDetailScreen extends StatelessWidget {
  const VocabularyWordDetailScreen({
    super.key,
    required this.word,
  });

  final WordModel word;

  @override
  Widget build(BuildContext context) {
    final uiModel = _convertToUiModel(word);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(word.content),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          0,
          screenHeight * 0.15,
          0,
          40,
        ),
        child: _buildCard(
          context: context,
          model: uiModel,
        ),
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required ui.WordModel model,
  }) {
    final onTapSaveVocabulary = () {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => VocabularySelectBottomSheet(
          content: _toLearningContentModel(word),
        ),
      );
    };

    switch (word.contentType) {
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

  ui.WordModel _convertToUiModel(WordModel word) {
    return ui.WordModel(
      id: word.id,
      category: '',
      subCategory: word.subCategory,
      contentType: word.contentType,
      content: word.content,
      meaning: word.meaning,
      isActive: true,
      furigana: word.furigana,
      romaji: word.romaji,
      pronunciationKr: word.pronunciationKr,
      examples: word.examples
          .map(
            (example) => ui.WordExample(
          content: example.content,
          meaning: example.meaning,
        ),
      )
          .toList(),
    );
  }

  LearningContentModel _toLearningContentModel(WordModel word) {
    return LearningContentModel(
      id: word.id,
      category: '',
      subCategory: word.subCategory,
      contentType: word.contentType,
      content: word.content,
      meaning: word.meaning,
      sourceId: '',
      isActive: true,
      createdAt: word.createdAt,
      updatedAt: word.updatedAt,
      furigana: word.furigana,
      romaji: word.romaji,
      onReading: '',
      kunReading: '',
      pronunciationKr: word.pronunciationKr,
      order: null,
      examples: word.examples
          .map(
            (example) => LearningContentExampleModel(
          content: example.content,
          furigana: null,
          meaning: example.meaning,
        ),
      )
          .toList(),
    );
  }
}