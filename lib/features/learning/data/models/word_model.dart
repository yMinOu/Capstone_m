// ============================================================
// Firestore learning_contents 컬렉션 문서 모델
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class WordExample {
  final String content; // 일본어 예문
  final String meaning; // 예문 뜻

  const WordExample({
    required this.content,
    required this.meaning,
  });

  factory WordExample.fromMap(Map<String, dynamic> map) {
    return WordExample(
      content: map['content'] as String? ?? '',
      meaning: map['meaning'] as String? ?? '',
    );
  }
}

class WordModel {
  final String id; // 문서 ID
  final String category; // 큰 분류 (예: jlpt, hiragana, katakana)
  final String subCategory; // 세부 분류 (예: N1)
  final String contentType; // 데이터 종류 (예: word, kanji, sentence)
  final String content; // 한자/단어/문자
  final String furigana; // 후리가나
  final String romaji; // 로마자
  final List<String> meaning; // 의미 목록
  final List<WordExample> examples; // 예문 목록
  final bool isActive;

  const WordModel({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.contentType,
    required this.content,
    required this.furigana,
    required this.romaji,
    required this.meaning,
    required this.examples,
    required this.isActive,
  });

  factory WordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WordModel(
      id: doc.id,
      category: data['category'] as String? ?? '',
      subCategory: data['subCategory'] as String? ?? '',
      contentType: data['contentType'] as String? ?? 'word',
      content: data['content'] as String? ?? '',
      furigana: data['furigana'] as String? ?? '',
      romaji: data['romaji'] as String? ?? '',
      meaning: List<String>.from(data['meaning'] as List? ?? []),
      examples: (data['examples'] as List? ?? [])
          .map((e) => WordExample.fromMap(e as Map<String, dynamic>))
          .toList(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}