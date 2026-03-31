/// 내 단어 탭에서 사용하는 학습 단어 모델
import 'package:cloud_firestore/cloud_firestore.dart';

class LearningProgressModel {
  final String id;
  final String category;
  final String subCategory;
  final String contentType;
  final String content;
  final String meaning;
  final String status;
  final DateTime? lastStudiedAt;
  final DateTime? addedToWordbookAt;
  final DateTime? updatedAt;

  const LearningProgressModel({
    required this.id,
    required this.category,
    required this.subCategory,
    required this.contentType,
    required this.content,
    required this.meaning,
    required this.status,
    required this.lastStudiedAt,
    required this.addedToWordbookAt,
    required this.updatedAt,
  });

  factory LearningProgressModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return LearningProgressModel(
      id: doc.id,
      category: (data['category'] ?? '') as String,
      subCategory: (data['subCategory'] ?? '') as String,
      contentType: (data['contentType'] ?? '') as String,
      content: (data['content'] ?? '') as String,
      meaning: ((data['meaning'] ?? data['meaing']) ?? '') as String,
      status: (data['status'] ?? 'unseen') as String,
      lastStudiedAt: _toNullableDateTime(data['lastStudiedAt']),
      addedToWordbookAt: _toNullableDateTime(data['addedToWordbookAt']),
      updatedAt: _toNullableDateTime(data['updatedAt']),
    );
  }

  static DateTime? _toNullableDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}