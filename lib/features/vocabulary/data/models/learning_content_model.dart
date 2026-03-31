/// learning_contents 원본 학습 데이터 모델
import 'package:cloud_firestore/cloud_firestore.dart';

class LearningContentExampleModel {
  final String content;
  final String? furigana;
  final String meaning;

  const LearningContentExampleModel({
    required this.content,
    required this.furigana,
    required this.meaning,
  });

  factory LearningContentExampleModel.fromMap(Map<String, dynamic> map) {
    return LearningContentExampleModel(
      content: (map['content'] ?? '') as String,
      furigana: map['furigana'] as String?,
      meaning: (map['meaning'] ?? '') as String,
    );
  }
}

class LearningContentModel {
  final String id;
  final String category;
  final String subCategory;
  final String contentType;
  final String content;
  final List<String> meaning;
  final String sourceId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String furigana;
  final String romaji;
  final String onReading;
  final String kunReading;
  final String pronunciationKr;
  final int? order;
  final List<LearningContentExampleModel> examples;

  const LearningContentModel({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.contentType,
    required this.content,
    required this.meaning,
    required this.sourceId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.furigana,
    required this.romaji,
    required this.onReading,
    required this.kunReading,
    required this.pronunciationKr,
    required this.order,
    required this.examples,
  });

  factory LearningContentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};
    final rawMeaning = (data['meaning'] as List<dynamic>? ?? []);
    final rawExamples = (data['examples'] as List<dynamic>? ?? []);

    return LearningContentModel(
      id: doc.id,
      category: (data['category'] ?? '') as String,
      subCategory: (data['subCategory'] ?? '') as String,
      contentType: (data['contentType'] ?? '') as String,
      content: (data['content'] ?? '') as String,
      meaning: rawMeaning.map((e) => e.toString()).toList(),
      sourceId: (data['sourceId'] ?? '') as String,
      isActive: (data['isActive'] ?? true) as bool,
      createdAt: _toNullableDateTime(data['createdAt']),
      updatedAt: _toNullableDateTime(data['updatedAt']),
      furigana: (data['furigana'] ?? '') as String,
      romaji: (data['romaji'] ?? '') as String,
      onReading: (data['onReading'] ?? '') as String,
      kunReading: (data['kunReading'] ?? '') as String,
      pronunciationKr: (data['pronunciationKr'] ?? '') as String,
      order: data['order'] as int?,
      examples: rawExamples
          .whereType<Map<String, dynamic>>()
          .map(LearningContentExampleModel.fromMap)
          .toList(),
    );
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}