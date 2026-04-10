// 학습 화면 상태 관리 Provider

import 'package:cloud_firestore/cloud_firestore.dart';
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

// ============================================================
// 페이지네이션 상태
// ============================================================

class PaginatedWordsState {
  final List<WordModel> words;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const PaginatedWordsState({
    this.words = const [],
    this.isInitialLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  PaginatedWordsState copyWith({
    List<WordModel>? words,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return PaginatedWordsState(
      words: words ?? this.words,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

// ============================================================
// 페이지네이션 Notifier
// ============================================================

class PaginatedWordsNotifier extends StateNotifier<PaginatedWordsState> {
  final WordRepository _repository;
  final String _level;
  final String _type;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  static const int _pageSize = 30;

  PaginatedWordsNotifier({
    required WordRepository repository,
    required String level,
    required String type,
  })  : _repository = repository,
        _level = level,
        _type = type,
        super(const PaginatedWordsState()) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final result = await _repository.fetchPaginated(
        type: _type,
        level: _level,
        lastDocument: null,
        pageSize: _pageSize,
      );
      _lastDocument = result.lastDocument;
      state = PaginatedWordsState(
        words: result.words,
        isInitialLoading: false,
        hasMore: result.words.length >= _pageSize,
      );
    } catch (e) {
      state = PaginatedWordsState(
        isInitialLoading: false,
        hasMore: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !state.hasMore || state.isInitialLoading) return;
    _isLoading = true;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _repository.fetchPaginated(
        type: _type,
        level: _level,
        lastDocument: _lastDocument,
        pageSize: _pageSize,
      );
      _lastDocument = result.lastDocument;
      state = state.copyWith(
        words: [...state.words, ...result.words],
        isLoadingMore: false,
        hasMore: result.words.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    } finally {
      _isLoading = false;
    }
  }
}

// ============================================================
// 페이지네이션 Provider
// ============================================================

final paginatedWordProvider = StateNotifierProvider.autoDispose
    .family<PaginatedWordsNotifier, PaginatedWordsState, String>(
  (ref, level) => PaginatedWordsNotifier(
    repository: ref.read(wordRepositoryProvider),
    level: level,
    type: 'word',
  ),
);

final paginatedKanjiProvider = StateNotifierProvider.autoDispose
    .family<PaginatedWordsNotifier, PaginatedWordsState, String>(
  (ref, level) => PaginatedWordsNotifier(
    repository: ref.read(wordRepositoryProvider),
    level: level,
    type: 'kanji',
  ),
);

final paginatedSentenceProvider = StateNotifierProvider.autoDispose
    .family<PaginatedWordsNotifier, PaginatedWordsState, String>(
  (ref, level) => PaginatedWordsNotifier(
    repository: ref.read(wordRepositoryProvider),
    level: level,
    type: 'sentence',
  ),
);

// ============================================================
// 카테고리 목록 Provider (기존 유지)
// ============================================================

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

// 한자 카테고리 목록
final kanjiCategoryProvider = Provider<List<WordCategory>>((ref) {
  return const [
    WordCategory(id: 'N5', title: 'JLPT N5 필수 한자'),
    WordCategory(id: 'N4', title: 'JLPT N4 필수 한자'),
    WordCategory(id: 'N3', title: 'JLPT N3 필수 한자'),
    WordCategory(id: 'N2', title: 'JLPT N2 필수 한자'),
    WordCategory(id: 'N1', title: 'JLPT N1 필수 한자'),
  ];
});

// 히라가나 목록 (Firestore 조회)
final hiraganaListProvider = FutureProvider<List<WordModel>>((ref) async {
  final repository = ref.read(wordRepositoryProvider);
  return repository.fetchHiragana();
});

// 가타카나 목록 (Firestore 조회)
final katakanaListProvider = FutureProvider<List<WordModel>>((ref) async {
  final repository = ref.read(wordRepositoryProvider);
  return repository.fetchKatakana();
});
