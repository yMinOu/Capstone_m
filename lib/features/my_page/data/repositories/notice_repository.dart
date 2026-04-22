import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nihongo/features/my_page/data/models/notice_model.dart';

class NoticeRepository {
  final _col = FirebaseFirestore.instance.collection('notices');

  Stream<List<NoticeModel>> watchNotices() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(NoticeModel.fromDoc).toList());
  }

  Future<void> createNotice({
    required String uid,
    required String title,
    required String content,
  }) async {
    final notice = NoticeModel(
      id: '',
      title: title,
      content: content,
      authorUid: uid,
      createdAt: DateTime.now(),
    );
    await _col.add(notice.toMap(uid));
  }

  Future<void> deleteNotice(String noticeId) async {
    await _col.doc(noticeId).delete();
  }
}
