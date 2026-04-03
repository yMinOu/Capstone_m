/// 역할: 단어장 퀴즈 1문제 데이터를 정의합니다.
import 'package:nihongo/features/vocabulary/data/models/word_model.dart';

class VocabularyQuizQuestionModel {
  VocabularyQuizQuestionModel({
    required this.word,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
  });

  final WordModel word;
  final String questionText;
  final String correctAnswer;
  final List<String> options;
}