// 학습 화면 상태 관리 Provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';
import 'package:nihongo/features/learning/data/repositories/word_repository.dart';
import 'package:nihongo/features/learning/data/repositories/user_repository.dart';
import 'package:nihongo/features/learning/data/repositories/study_stats_repository.dart';
import 'package:nihongo/features/learning/data/repositories/learning_progress_repository.dart';


// 단어 카테고리

class WordCategory {
  final String id;    // Firestore 문서 ID 접두사 (예: 'N5', 'N4')
  final String title; // 화면에 표시할 카테고리 이름

  const WordCategory({required this.id, required this.title});
}


// WordRepository 인스턴스

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return WordRepository();
});

// UserRepository 인스턴스

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// StudyStatsRepository 인스턴스

final studyStatsRepositoryProvider = Provider<StudyStatsRepository>((ref) {
  return StudyStatsRepository();
});

// LearningProgressRepository 인스턴스

final learningProgressRepositoryProvider = Provider<LearningProgressRepository>((ref) {
  return LearningProgressRepository();
});


// 단어 카테고리 목록
final wordCategoryProvider = Provider<List<WordCategory>>((ref) {
  return const [
    WordCategory(id: 'N5', title: 'JLPT N5 필수 단어'),
    WordCategory(id: 'N4', title: 'JLPT N4 필수 단어'),
    WordCategory(id: 'N3', title: 'JLPT N3 필수 단어'),
    WordCategory(id: 'N2', title: 'JLPT N2 필수 단어'),
    WordCategory(id: 'N1', title: 'JLPT N1 필수 단어'),
  ];
});

// 레벨별 단어 목록 (Firestore 조회)
final wordListProvider =
    FutureProvider.family<List<WordModel>, String>((ref, level) async {
  final repository = ref.read(wordRepositoryProvider);
  return repository.fetchWordsByLevel(level);
});

// 예문 카테고리 목록
final sentenceCategoryProvider = Provider<List<WordCategory>>((ref) {
  return const [
    WordCategory(id: 'N5', title: 'JLPT N5 필수 예문'),
    WordCategory(id: 'N4', title: 'JLPT N4 필수 예문'),
    WordCategory(id: 'N3', title: 'JLPT N3 필수 예문'),
    WordCategory(id: 'N2', title: 'JLPT N2 필수 예문'),
    WordCategory(id: 'N1', title: 'JLPT N1 필수 예문'),
  ];
});

// 레벨별 예문 목록 (Firestore 조회)
final sentenceListProvider =
    FutureProvider.family<List<WordModel>, String>((ref, level) async {
  final repository = ref.read(wordRepositoryProvider);
  return repository.fetchSentencesByLevel(level);
});
