/// 단어장 데이터 모델
import 'package:cloud_firestore/cloud_firestore.dart';

class VocabularyModel {
  final String id;
  final String title;
  final String? description;
  final int wordCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VocabularyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.wordCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabularyModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return VocabularyModel(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      description: data['description'] as String?,
      wordCount: (data['wordCount'] ?? 0) as int,
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'wordCount': wordCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  VocabularyModel copyWith({
    String? id,
    String? title,
    String? description,
    int? wordCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VocabularyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      wordCount: wordCount ?? this.wordCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime.now();
  }
}