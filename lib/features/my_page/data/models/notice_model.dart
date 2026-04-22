import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String id;
  final String title;
  final String content;
  final String authorUid;
  final DateTime createdAt;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorUid,
    required this.createdAt,
  });

  factory NoticeModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoticeModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      authorUid: data['authorUid'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap(String uid) => {
    'title': title,
    'content': content,
    'authorUid': uid,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
