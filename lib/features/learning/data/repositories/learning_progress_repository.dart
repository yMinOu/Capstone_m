// ============================================================
// 학습 진행 Repository - users/{uid}/learning_progress 서브컬렉션 담당
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';

class LearningProgressRepository {
  final FirebaseFirestore _firestore;

  LearningProgressRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _progressRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('learning_progress');

  // TODO [임시]: 개발 테스트용 전체 학습 기록 삭제 - 배포 전 제거할 것
  Future<void> resetProgress({
    required String uid,
    required String subCategory,
  }) async {
    final snapshot = await _progressRef(uid)
        .where('subCategory', isEqualTo: subCategory)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // 알아요 / 몰라요 누를 때 status 저장
  // status: "know" or "dontKnow"
  Future<void> updateStatus({
    required String uid,
    required WordModel word,
    required String status,
  }) async {
    await _progressRef(uid).doc(word.id).set({
      'category': 'word',
      'subCategory': word.subCategory,
      'contentType': 'flashcard',
      'content': word.content,
      'meaning': word.meaning.isNotEmpty ? word.meaning.first : '',
      'status': status,
      'lastStudiedAt': FieldValue.serverTimestamp(),
      'addedToWordbookAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 특정 레벨의 know / dontKnow 카운트 + 처리된 단어 ID 목록 조회
  Future<({int knownCount, int unknownCount, Set<String> processedIds})> getProgressCount({
    required String uid,
    required String subCategory,
  }) async {
    final snapshot = await _progressRef(uid)
        .where('subCategory', isEqualTo: subCategory)
        .where('status', whereIn: ['know', 'dontKnow'])
        .get();

    int knownCount = 0;
    int unknownCount = 0;
    final processedIds = <String>{};

    for (final doc in snapshot.docs) {
      final status = (doc.data() as Map<String, dynamic>)['status'];
      processedIds.add(doc.id);
      if (status == 'know') {
        knownCount++;
      } else if (status == 'dontKnow') {
        unknownCount++;
      }
    }

    return (knownCount: knownCount, unknownCount: unknownCount, processedIds: processedIds);
  }
}
