/// 단어장 상태 관리 provider
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_content_model.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_progress_model.dart';
import 'package:nihongo/features/vocabulary/data/models/vocabulary_model.dart';
import 'package:nihongo/features/vocabulary/data/models/word_model.dart';
import 'package:nihongo/features/vocabulary/data/repositories/vocabulary_repository.dart';

final learningContentDetailProvider =
FutureProvider.family<LearningContentModel, String>((ref, contentId) {
  final repository = ref.read(vocabularyRepositoryProvider);
  return repository.getLearningContentById(contentId: contentId);
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return VocabularyRepository(
    firestore: ref.read(firebaseFirestoreProvider),
    auth: ref.read(firebaseAuthProvider),
  );
});

final vocabularyListProvider = StreamProvider<List<VocabularyModel>>((ref) {
  final repository = ref.read(vocabularyRepositoryProvider);
  return repository.watchVocabularies();
});

final vocabularyLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

class VocabularyActionNotifier extends StateNotifier<AsyncValue<void>> {
  VocabularyActionNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  VocabularyRepository get _repository =>
      _ref.read(vocabularyRepositoryProvider);

  Future<bool> createVocabulary({
    required String title,
    String? description,
  }) async {
    final trimmedTitle = title.trim();

    if (trimmedTitle.isEmpty) {
      state = AsyncError(
        Exception('단어장 이름을 입력해주세요.'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    _ref.read(vocabularyLoadingProvider.notifier).state = true;

    try {
      await _repository.createVocabulary(
        title: trimmedTitle,
        description: description,
      );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    } finally {
      _ref.read(vocabularyLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteVocabulary({
    required String vocabularyId,
  }) async {
    state = const AsyncLoading();

    try {
      await _repository.deleteVocabulary(vocabularyId: vocabularyId);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final vocabularyActionProvider =
StateNotifierProvider<VocabularyActionNotifier, AsyncValue<void>>((ref) {
  return VocabularyActionNotifier(ref);
});

final vocabularyWordsProvider =
StreamProvider.family<List<WordModel>, String>((ref, vocabularyId) {
  final repository = ref.read(vocabularyRepositoryProvider);
  return repository.watchWords(vocabularyId: vocabularyId);
});

final wordLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

class WordActionNotifier extends StateNotifier<AsyncValue<void>> {
  WordActionNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  VocabularyRepository get _repository =>
      _ref.read(vocabularyRepositoryProvider);

  Future<bool> addLearningContentToVocabulary({
    required String vocabularyId,
    required LearningContentModel content,
  }) async {
    state = const AsyncLoading();
    _ref.read(wordLoadingProvider.notifier).state = true;

    try {
      await _repository.addLearningContentToVocabulary(
        vocabularyId: vocabularyId,
        content: content,
      );
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    } finally {
      _ref.read(wordLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteWord({
    required String vocabularyId,
    required String wordId,
  }) async {
    state = const AsyncLoading();
    _ref.read(wordLoadingProvider.notifier).state = true;

    try {
      await _repository.deleteWord(
        vocabularyId: vocabularyId,
        wordId: wordId,
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      _ref.read(wordLoadingProvider.notifier).state = false;
    }
  }
}

final wordActionProvider =
StateNotifierProvider<WordActionNotifier, AsyncValue<void>>((ref) {
  return WordActionNotifier(ref);
});

class LearningProgressPagingState {
  const LearningProgressPagingState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.initialized = false,
    this.errorMessage,
    this.lastDocument,
    this.newestUpdatedAt,
  });

  final List<LearningProgressModel> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasMore;
  final bool initialized;
  final String? errorMessage;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final DateTime? newestUpdatedAt;

  LearningProgressPagingState copyWith({
    List<LearningProgressModel>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasMore,
    bool? initialized,
    String? errorMessage,
    bool clearErrorMessage = false,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    bool keepLastDocument = true,
    DateTime? newestUpdatedAt,
    bool keepNewestUpdatedAt = true,
  }) {
    return LearningProgressPagingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      initialized: initialized ?? this.initialized,
      errorMessage:
      clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      lastDocument:
      keepLastDocument ? (lastDocument ?? this.lastDocument) : lastDocument,
      newestUpdatedAt: keepNewestUpdatedAt
          ? (newestUpdatedAt ?? this.newestUpdatedAt)
          : newestUpdatedAt,
    );
  }
}

class LearningProgressPagingNotifier
    extends StateNotifier<LearningProgressPagingState> {
  LearningProgressPagingNotifier(this._ref)
      : super(const LearningProgressPagingState());

  final Ref _ref;

  static const int _pageSize = 20;

  VocabularyRepository get _repository =>
      _ref.read(vocabularyRepositoryProvider);

  Future<void> ensureInitialized() async {
    if (state.initialized || state.isLoading) {
      return;
    }
    await loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      initialized: false,
      clearErrorMessage: true,
      items: const [],
      hasMore: true,
      lastDocument: null,
      keepLastDocument: false,
      newestUpdatedAt: null,
      keepNewestUpdatedAt: false,
    );

    try {
      final page = await _repository.fetchLearningProgressWordsPage(
        limit: _pageSize,
      );

      state = state.copyWith(
        items: page.items,
        isLoading: false,
        hasMore: page.hasMore,
        initialized: true,
        lastDocument: page.lastDocument,
        keepLastDocument: false,
        newestUpdatedAt:
        page.items.isEmpty ? null : _extractUpdatedAt(page.items.first),
        keepNewestUpdatedAt: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        initialized: true,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.initialized ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    final lastDocument = state.lastDocument;
    if (lastDocument == null) {
      return;
    }

    state = state.copyWith(
      isLoadingMore: true,
      clearErrorMessage: true,
    );

    try {
      final page = await _repository.fetchLearningProgressWordsPage(
        lastDocument: lastDocument,
        limit: _pageSize,
      );

      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
        lastDocument: page.lastDocument,
        keepLastDocument: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshOnlyNew() async {
    if (!state.initialized || state.isLoading || state.isRefreshing) {
      return;
    }

    final newestUpdatedAt = state.newestUpdatedAt;
    if (newestUpdatedAt == null) {
      await loadInitial();
      return;
    }

    state = state.copyWith(
      isRefreshing: true,
      clearErrorMessage: true,
    );

    try {
      final newItems = await _repository.fetchNewerLearningProgressWords(
        newestUpdatedAt: newestUpdatedAt,
      );

      if (newItems.isEmpty) {
        state = state.copyWith(isRefreshing: false);
        return;
      }

      final existingIds = state.items.map((item) => item.id).toSet();
      final uniqueNewItems = newItems
          .where((item) => !existingIds.contains(item.id))
          .toList();

      state = state.copyWith(
        items: [...uniqueNewItems, ...state.items],
        isRefreshing: false,
        newestUpdatedAt:
        _extractUpdatedAt(newItems.first) ?? state.newestUpdatedAt,
        keepNewestUpdatedAt: false,
      );
    } catch (error) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshOnTabOpen() async {
    if (state.isLoading || state.isRefreshing) {
      return;
    }

    if (!state.initialized) {
      await loadInitial();
      return;
    }

    await refreshOnlyNew();
  }

  void updateItemStatus({
    required String contentId,
    required String status,
  }) {
    final updatedItems = state.items.map((item) {
      if (item.id != contentId) {
        return item;
      }

      return item.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }).toList();

    updatedItems.sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    state = state.copyWith(
      items: updatedItems,
      newestUpdatedAt: updatedItems.isEmpty
          ? state.newestUpdatedAt
          : (updatedItems.first.updatedAt ?? state.newestUpdatedAt),
      keepNewestUpdatedAt: false,
    );
  }

  DateTime? _extractUpdatedAt(LearningProgressModel item) {
    return item.updatedAt;
  }
}

final learningProgressPagingProvider = StateNotifierProvider<
    LearningProgressPagingNotifier, LearningProgressPagingState>((ref) {
  return LearningProgressPagingNotifier(ref);
});

class LearningProgressActionNotifier extends StateNotifier<AsyncValue<void>> {
  LearningProgressActionNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  VocabularyRepository get _repository =>
      _ref.read(vocabularyRepositoryProvider);

  Future<void> updateStatus({
    required String contentId,
    required String status,
  }) async {
    state = const AsyncLoading();

    try {
      await _repository.updateLearningStatus(
        contentId: contentId,
        status: status,
      );

      _ref.read(learningProgressPagingProvider.notifier).updateItemStatus(
        contentId: contentId,
        status: status,
      );

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final learningProgressActionProvider =
StateNotifierProvider<LearningProgressActionNotifier, AsyncValue<void>>(
      (ref) => LearningProgressActionNotifier(ref),
);