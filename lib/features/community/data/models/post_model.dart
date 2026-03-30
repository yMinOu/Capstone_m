import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final List<String> likes;
  final int commentCount;

  PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.likes = const [],
    this.commentCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'category': category,
      'createdAt': createdAt,
      'likes': likes,
      'commentCount': commentCount,
    };
  }

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    final authorId = data?['authorId'] as String? ?? '';
    final authorName = data?['authorName'] as String? ?? '익명';
    final title = data?['title'] as String? ?? '';
    final content = data?['content'] as String? ?? '';
    final category = data?['category'] as String? ?? '';
    
    // likes 필드를 안전하게 파싱: null이거나 리스트가 아닌 경우 빈 리스트 반환
    final likesRaw = data?['likes'];
    final List<String> likes = (likesRaw is List) 
        ? likesRaw.map((e) => e.toString()).toList() 
        : [];
        
    final commentCount = data?['commentCount'] as int? ?? 0;
    
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

    return PostModel(
      id: doc.id,
      authorId: authorId,
      authorName: authorName,
      title: title,
      content: content,
      category: category,
      createdAt: createdAt,
      likes: likes,
      commentCount: commentCount,
    );
  }
}
