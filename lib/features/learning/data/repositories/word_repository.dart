// ============================================================
// 단어 Repository - Firestore learning_contents 컬렉션 쿼리
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';

class WordRepository {
  final FirebaseFirestore _firestore;

  WordRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 페이지네이션 지원 - type: 'word' | 'kanji' | 'sentence'
  Future<({List<WordModel> words, DocumentSnapshot? lastDocument})> fetchPaginated({
    required String type,
    required String level,
    DocumentSnapshot? lastDocument,
    int pageSize = 30,
  }) async {
    Query query = _firestore
        .collection('learning_contents')
        .where('subCategory', isEqualTo: level)
        .where('isActive', isEqualTo: true)
        .where('contentType', isEqualTo: type)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return (
      words: snapshot.docs.map((doc) => WordModel.fromFirestore(doc)).toList(),
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
    );
  }

  // 전체 단어 수 조회
  Future<int> fetchTotalCount({
    required String type,
    required String level,
  }) async {
    final snapshot = await _firestore
        .collection('learning_contents')
        .where('subCategory', isEqualTo: level)
        .where('isActive', isEqualTo: true)
        .where('contentType', isEqualTo: type)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // 히라가나 목록 가져오기 (46자로 적어 페이지네이션 불필요)
  Future<List<WordModel>> fetchHiragana() async {
    final snapshot = await _firestore
        .collection('learning_contents')
        .where('category', isEqualTo: 'hiragana')
        .where('isActive', isEqualTo: true)
        .where('contentType', isEqualTo: 'character')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => WordModel.fromFirestore(doc))
        .toList();
  }

  // 가타카나 목록 가져오기 (46자로 적어 페이지네이션 불필요)
  Future<List<WordModel>> fetchKatakana() async {
    final snapshot = await _firestore
        .collection('learning_contents')
        .where('category', isEqualTo: 'katakana')
        .where('isActive', isEqualTo: true)
        .where('contentType', isEqualTo: 'character')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => WordModel.fromFirestore(doc))
        .toList();
  }
}
