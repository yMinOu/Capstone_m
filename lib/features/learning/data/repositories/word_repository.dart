// ============================================================
// 단어 Repository - Firestore learning_contents 컬렉션 쿼리
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';

class WordRepository {
  final FirebaseFirestore _firestore;

  WordRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 특정 레벨(N1~N5)의 단어 목록 가져오기
  Future<List<WordModel>> fetchWordsByLevel(String level) async {
    final snapshot = await _firestore
        .collection('learning_contents')
        .where('subCategory', isEqualTo: level)
        .where('isActive', isEqualTo: true)
        .where('contentType', isEqualTo: 'word')
        .get();

    return snapshot.docs
        .map((doc) => WordModel.fromFirestore(doc))
        .toList();
  }

  // 특정 레벨(N1~N5)의 예문 목록 가져오기
  Future<List<WordModel>> fetchSentencesByLevel(String level) async {
    final snapshot = await _firestore
        .collection('learning_contents')
        .where('subCategory', isEqualTo: level)
        .where('isActive', isEqualTo: true)
        .where('contentType', isEqualTo: 'sentence')
        .get();

    return snapshot.docs
        .map((doc) => WordModel.fromFirestore(doc))
        .toList();
  }

  // 특정 레벨(N1~N5)의 한자 목록 가져오기
  Future<List<WordModel>> fetchKanjiByLevel(String level) async {
    final snapshot = await _firestore
        .collection('learning_contents')
        .where('subCategory', isEqualTo: level)
        .where('isActive', isEqualTo: true)
        .where('contentType', isEqualTo: 'kanji')
        .get();

    return snapshot.docs
        .map((doc) => WordModel.fromFirestore(doc))
        .toList();
  }
}
