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
    });
  }

  // users/{uid}.totalStudyCount +1
  Future<void> incrementStudyCount(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'totalStudyCount': FieldValue.increment(1),
    });
  }
}
