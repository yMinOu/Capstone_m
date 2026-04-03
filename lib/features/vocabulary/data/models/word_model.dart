/// 학습/상세 카드 공통 단어 모델
import 'package:cloud_firestore/cloud_firestore.dart';

class WordModel {
  final String id;
  final String content;
  final List<String> meaning;
  final String furigana;
  final String romaji;
  final String status;
  final String subCategory;
  final String pronunciationKr;
  final String contentType;
  final List<WordExample> examples;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WordModel({
    required this.id,
    required this.content,
    required this.meaning,
    this.furigana = '',
    this.romaji = '',
    this.status = '',
    this.subCategory = '',
    this.pronunciationKr = '',
    this.contentType = 'word',
    this.examples = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory WordModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return WordModel(
      id: doc.id,
      content: (data['word'] ?? data['content'] ?? '') as String,
      meaning: data['meaning'] is List
          ? List<String>.from(data['meaning'])
          : [(data['meaning'] ?? '') as String],
      furigana: (data['furigana'] ?? '') as String,
      romaji: (data['romaji'] ?? '') as String,
      status: (data['status'] ?? '') as String,
      subCategory: (data['subCategory'] ?? '') as String,
      pronunciationKr: (data['pronunciationKr'] ?? '') as String,
      contentType: (data['contentType'] ?? 'word') as String,
      examples: (data['examples'] as List<dynamic>? ?? [])
          .map(
            (e) => WordExample(
          content: (e['content'] ?? '') as String,
          meaning: (e['meaning'] ?? '') as String,
        ),
      )
          .toList(),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
  }
}

class WordExample {
  final String content;
  final String meaning;

  const WordExample({
    required this.content,
    required this.meaning,
  });
}