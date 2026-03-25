// ============================================================
// 단어 Repository - Firestore learning_contents 컬렉션 쿼리
// 문서 ID가 N5_word_XXXX 형태이므로 범위 쿼리로 레벨 필터링
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';

class WordRepository {
  final FirebaseFirestore _firestore;

  WordRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 특정 레벨(N1~N5)의 단어 목록 가져오기
  // level 예: 'N5', 'N4', 'N3', 'N2', 'N1'
  Future<List<WordModel>> fetchWordsByLevel(String level) async {
    final snapshot = await _firestore
        .collection('learning_contents')
        .where('subCategory', isEqualTo: level)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => WordModel.fromFirestore(doc))
        .toList();
  }
}
