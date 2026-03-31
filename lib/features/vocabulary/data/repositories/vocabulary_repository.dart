/// 단어장 Firestore 접근 repository
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nihongo/features/vocabulary/data/models/vocabulary_model.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_progress_model.dart';
import 'package:nihongo/features/vocabulary/data/models/word_model.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_content_model.dart';

class VocabularyRepository {
  VocabularyRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _vocabulariesRef {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('vocabularies');
  }

  Stream<List<VocabularyModel>> watchVocabularies() {
    return _vocabulariesRef
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(VocabularyModel.fromFirestore)
          .toList(),
    );
  }

  Future<void> createVocabulary({
    required String title,
    String? description,
  }) async {
    final now = DateTime.now();

    await _vocabulariesRef.add({
      'title': title.trim(),
      'description': _normalizeDescription(description),
      'wordCount': 0,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  Future<void> deleteVocabulary({
    required String vocabularyId,
  }) async {
    final vocabularyDoc = _vocabulariesRef.doc(vocabularyId);
    final wordsSnapshot = await vocabularyDoc.collection('words').get();

    final batch = _firestore.batch();

    for (final doc in wordsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(vocabularyDoc);

    await batch.commit();
  }

  Future<void> addWord({
    required String vocabularyId,
    required Map<String, dynamic> wordData,
  }) async {
    final vocabularyDoc = _vocabulariesRef.doc(vocabularyId);
    final wordDoc = vocabularyDoc.collection('words').doc();
    final now = Timestamp.fromDate(DateTime.now());

    await _firestore.runTransaction((transaction) async {
      transaction.set(wordDoc, {
        ...wordData,
        'createdAt': now,
        'updatedAt': now,
      });

      transaction.update(vocabularyDoc, {
        'wordCount': FieldValue.increment(1),
        'updatedAt': now,
      });
    });
  }

  Future<void> deleteWord({
    required String vocabularyId,
    required String wordId,
  }) async {
    final vocabularyDoc = _vocabulariesRef.doc(vocabularyId);
    final wordDoc = vocabularyDoc.collection('words').doc(wordId);
    final now = Timestamp.fromDate(DateTime.now());

    await _firestore.runTransaction((transaction) async {
      transaction.delete(wordDoc);
      transaction.update(vocabularyDoc, {
        'wordCount': FieldValue.increment(-1),
        'updatedAt': now,
      });
    });
  }

  String? _normalizeDescription(String? description) {
    if (description == null) {
      return null;
    }

    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  Stream<List<WordModel>> watchWords({
    required String vocabularyId,
  }) {
    return _vocabulariesRef
        .doc(vocabularyId)
        .collection('words')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(WordModel.fromFirestore)
          .toList(),
    );
  }

  Future<void> createWord({
    required String vocabularyId,
    required String word,
    required String meaning,
  }) async {
    final trimmedWord = word.trim();
    final trimmedMeaning = meaning.trim();

    if (trimmedWord.isEmpty || trimmedMeaning.isEmpty) {
      throw Exception('단어와 의미를 모두 입력해주세요.');
    }

    await addWord(
      vocabularyId: vocabularyId,
      wordData: {
        'word': trimmedWord,
        'meaning': trimmedMeaning,
      },
    );
  }

  CollectionReference<Map<String, dynamic>> get _learningProgressRef {
    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('learning_progress');
  }

  Stream<List<LearningProgressModel>> watchLearningProgressWords() {
    return _learningProgressRef
        .orderBy('addedToWordbookAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(LearningProgressModel.fromFirestore)
          .toList(),
    );
  }

  CollectionReference<Map<String, dynamic>> get _learningContentsRef {
    return _firestore.collection('learning_contents');
  }

  Future<LearningContentModel> getLearningContentById({
    required String contentId,
  }) async {
    final doc = await _learningContentsRef.doc(contentId).get();

    if (!doc.exists) {
      throw Exception('학습 데이터를 찾을 수 없습니다.');
    }

    return LearningContentModel.fromFirestore(doc);
  }

  Future<void> updateLearningStatus({
    required String contentId,
    required String status, // "know" | "dontKnow"
  }) async {
    final doc = _learningProgressRef.doc(contentId);

    await doc.update({
      'status': status,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}