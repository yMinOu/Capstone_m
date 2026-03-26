// ============================================================
// 통계 Repository - users/{uid}/daily_stats 서브컬렉션 담당
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class StudyStatsRepository {
  final FirebaseFirestore _firestore;

  StudyStatsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 오늘 날짜 키 반환 (예: "2026-03-25")
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // 오늘 learnedCount 조회
  Future<int> getDailyLearnedCount(String uid) async {
    final dateKey = _todayKey();
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(dateKey)
        .get();

    if (!doc.exists) return 0;
    return (doc.data()?['learnedCount'] as int?) ?? 0;
  }

  // users/{uid}/daily_stats/{yyyy-MM-dd}.studySeconds 에 seconds 만큼 누적
  Future<void> addDailyStudySeconds(String uid, int seconds) async {
    if (seconds <= 0) return;
    final dateKey = _todayKey();
    final ref = _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(dateKey);

    await ref.set({
      'dateKey': dateKey,
      'studySeconds': FieldValue.increment(seconds),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // users/{uid}/daily_stats/{yyyy-MM-dd}.learnedCount +1
  Future<void> incrementDailyLearnedCount(String uid) async {
    final dateKey = _todayKey();
    final ref = _firestore
        .collection('users')
        .doc(uid)
        .collection('daily_stats')
        .doc(dateKey);

    await ref.set({
      'dateKey': dateKey,
      'learnedCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
