// 학습 화면 상태 관리 Provider

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/learning/data/models/word_model.dart';
import 'package:nihongo/features/learning/data/repositories/word_repository.dart';


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
// 사용: ref.watch(wordListProvider('N5'))
final wordListProvider =
    FutureProvider.family<List<WordModel>, String>((ref, level) async {
  final repository = ref.read(wordRepositoryProvider);
  return repository.fetchWordsByLevel(level);
});
