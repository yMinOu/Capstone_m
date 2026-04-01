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
      content: _asString(map['content']),
      furigana: map['furigana']?.toString(),
      meaning: _asMeaningString(map['meaning']),
    );
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String _asMeaningString(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.map((e) => e.toString()).join(', ');
    }
    return value.toString();
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
    final rawMeaning = data['meaning'];
    final rawExamples = (data['examples'] as List<dynamic>? ?? []);

    return LearningContentModel(
      id: doc.id,
      category: _asString(data['category']),
      subCategory: _asString(data['subCategory']),
      contentType: _asString(data['contentType']),
      content: _asString(data['content']),
      meaning: _asMeaningList(rawMeaning),
      sourceId: _asString(data['sourceId']),
      isActive: (data['isActive'] ?? true) as bool,
      createdAt: _toNullableDateTime(data['createdAt']),
      updatedAt: _toNullableDateTime(data['updatedAt']),
      furigana: _asString(data['furigana']),
      romaji: _asString(data['romaji']),
      onReading: _asString(data['onReading']),
      kunReading: _asString(data['kunReading']),
      pronunciationKr: _asString(data['pronunciationKr']),
      order: (data['order'] as num?)?.toInt(),
      examples: rawExamples
          .whereType<Map<String, dynamic>>()
          .map(LearningContentExampleModel.fromMap)
          .toList(),
    );
  }

  static List<String> _asMeaningList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [value.toString()];
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}