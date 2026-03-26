import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    DateTime createdAt;
    try {
      // 서버 타임스탬프가 아직 없는 경우를 대비해 estimate 옵션 사용 시도 (doc.get 방식)
      final rawCreatedAt = data?['createdAt'];
      if (rawCreatedAt is Timestamp) {
        createdAt = rawCreatedAt.toDate();
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
    );
  }
}
