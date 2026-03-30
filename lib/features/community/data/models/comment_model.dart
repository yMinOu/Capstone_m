import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final String? parentId; // 대댓글인 경우 부모 댓글의 ID

  CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.parentId,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    DateTime createdAt;
    try {
      final rawCreatedAt = data?['createdAt'];
      if (rawCreatedAt is Timestamp) {
        // Timestamp를 로컬 시간으로 변환
        createdAt = rawCreatedAt.toDate().toLocal();
      } else if (rawCreatedAt is String) {
        createdAt = DateTime.parse(rawCreatedAt).toLocal();
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    return CommentModel(
      id: doc.id,
      authorId: data?['authorId'] as String? ?? '',
      authorName: data?['authorName'] as String? ?? '익명',
      content: data?['content'] as String? ?? '',
      createdAt: createdAt,
      parentId: data?['parentId'] as String?,
    );
  }
}
