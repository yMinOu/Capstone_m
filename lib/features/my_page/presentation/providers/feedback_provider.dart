/// 의견(feedback) 관련 Riverpod providers.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/auth/presentation/providers/auth_provider.dart';
import 'package:nihongo/features/my_page/data/repositories/feedback_repository.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository();
});

class FeedbackItem {
  final String id;
  final String uid;
  final String content;
  final DateTime createdAt;

  const FeedbackItem({
    required this.id,
    required this.uid,
    required this.content,
    required this.createdAt,
  });

  factory FeedbackItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackItem(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

final feedbackListProvider = StreamProvider<List<FeedbackItem>>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('feedback')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(FeedbackItem.fromDoc).toList());
});
