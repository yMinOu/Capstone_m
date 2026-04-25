/// 사용자 의견을 Firestore feedback 컬렉션에 저장하는 repository.
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackRepository {
  final _col = FirebaseFirestore.instance.collection('feedback');

  Future<void> submitFeedback({
    required String uid,
    required String content,
  }) async {
    await _col.add({
      'uid': uid,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
