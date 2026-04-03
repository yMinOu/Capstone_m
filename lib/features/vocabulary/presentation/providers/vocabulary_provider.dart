/// 단어장 상태 관리 provider
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/vocabulary/data/models/vocabulary_model.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_progress_model.dart';
import 'package:nihongo/features/vocabulary/data/repositories/vocabulary_repository.dart';
import 'package:nihongo/features/vocabulary/data/models/word_model.dart';
import 'package:nihongo/features/vocabulary/data/models/learning_content_model.dart';

final learningContentDetailProvider =
FutureProvider.family<LearningContentModel, String>((ref, contentId) {
  final repository = ref.read(vocabularyRepositoryProvider);
  return repository.getLearningContentById(contentId: contentId);
});

final learningProgressListProvider =
StreamProvider<List<LearningProgressModel>>((ref) {
  final repository = ref.read(vocabularyRepositoryProvider);
  return repository.watchLearningProgressWords();
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

/// 특정 단어장의 단어 목록 조회
final vocabularyWordsProvider =
StreamProvider.family<List<WordModel>, String>((ref, vocabularyId) {
  final repository = ref.read(vocabularyRepositoryProvider);
  return repository.watchWords(vocabularyId: vocabularyId);
});

/// 단어 추가/삭제 로딩 상태
final wordLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

class WordActionNotifier extends StateNotifier<AsyncValue<void>> {
  WordActionNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

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
  VocabularyRepository get _repository =>
      _ref.read(vocabularyRepositoryProvider);

  Future<bool> createWord({
    required String vocabularyId,
    required String word,
    required String meaning,
  }) async {
    final trimmedWord = word.trim();
    final trimmedMeaning = meaning.trim();

    if (trimmedWord.isEmpty || trimmedMeaning.isEmpty) {
      state = AsyncError(
        Exception('단어와 의미를 모두 입력해주세요.'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    _ref.read(wordLoadingProvider.notifier).state = true;

    try {
      await _repository.createWord(
        vocabularyId: vocabularyId,
        word: trimmedWord,
        meaning: trimmedMeaning,
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

class LearningProgressActionNotifier extends StateNotifier<AsyncValue<void>> {
  LearningProgressActionNotifier(this._ref)
      : super(const AsyncData(null));

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
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final learningProgressActionProvider =
StateNotifierProvider<LearningProgressActionNotifier, AsyncValue<void>>(
        (ref) => LearningProgressActionNotifier(ref));