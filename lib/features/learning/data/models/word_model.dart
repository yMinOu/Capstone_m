// ============================================================
// Firestore learning_contents 컬렉션 문서 모델
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class WordExample {
  final String content; // 일본어 예문
  final String meaning; // 예문 뜻

  const WordExample({required this.content, required this.meaning});

  factory WordExample.fromMap(Map<String, dynamic> map) {
    return WordExample(
      content: map['content'] as String? ?? '',
      meaning: map['meaning'] as String? ?? '',
    );
  }
}

class WordModel {
  final String id;               // 문서 ID
  final String content;          // 한자/단어 (예: 同感)
  final String furigana;         // 후리가나 (예: どうかん)
  final String romaji;           // 로마자 (예: dokan)
  final List<String> meaning;      // 의미 목록
  final List<WordExample> examples; // 예문 목록
  final String subCategory;        // 레벨 (예: N1)
  final bool isActive;

  const WordModel({
    required this.id,
    required this.content,
    required this.furigana,
    required this.romaji,
    required this.meaning,
    required this.examples,
    required this.subCategory,
    required this.isActive,
  });

  factory WordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WordModel(
      id: doc.id,
      content: data['content'] as String? ?? '',
      furigana: data['furigana'] as String? ?? '',
      romaji: data['romaji'] as String? ?? '',
      meaning: List<String>.from(data['meaning'] as List? ?? []),
      examples: (data['examples'] as List? ?? [])
          .map((e) => WordExample.fromMap(e as Map<String, dynamic>))
          .toList(),
      subCategory: data['subCategory'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}
