// ============================================================
// 유저 데이터 Repository - Firestore users 컬렉션 업데이트 담당
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // users/{uid}.totalStudySeconds 에 seconds 만큼 누적
  Future<void> addStudySeconds(String uid, int seconds) async {
    if (seconds <= 0) return;
    await _firestore.collection('users').doc(uid).update({
      'totalStudySeconds': FieldValue.increment(seconds),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // users/{uid}.totalStudyCount +1
  Future<void> incrementStudyCount(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'totalStudyCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 연속 학습일 업데이트 - 하루에 한 번만 실행됨
  Future<void> updateStreakIfNeeded(String uid) async {
    final today = _todayKey();
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data() as Map<String, dynamic>?;
    final lastKey = data?['lastStudyDateKey'] as String?;

    // 오늘 이미 처리했으면 스킵
    if (lastKey == today) return;

    int newStreak;
    if (lastKey != null && _isYesterday(lastKey, today)) {
      // 어제 학습 → 연속 유지
      newStreak = ((data?['streakDays'] as int?) ?? 0) + 1;
    } else {
      // 오래됐거나 처음 → 리셋
      newStreak = 1;
    }

    await _firestore.collection('users').doc(uid).update({
      'streakDays': newStreak,
      'lastStudyDateKey': today,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool _isYesterday(String lastKey, String today) {
    try {
      final last = DateTime.parse(lastKey);
      final todayDate = DateTime.parse(today);
      return todayDate.difference(last).inDays == 1;
    } catch (_) {
      return false;
    }
  }
}
