import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/my_page/data/repositories/my_page_repository.dart';

final myPageRepositoryProvider = Provider<MyPageRepository>((ref) {
  return MyPageRepository();
});

class MyPageActionState {
  const MyPageActionState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  MyPageActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MyPageActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class MyPageActionNotifier extends StateNotifier<MyPageActionState> {
  MyPageActionNotifier(this._repository) : super(const MyPageActionState());

  final MyPageRepository _repository;

  Future<bool> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.logout();
      state = state.copyWith(isLoading: false, clearError: true);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그아웃 실패: ${e.message ?? e.code}',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그아웃 중 오류가 발생했습니다: $e',
      );
      return false;
    }
  }

  Future<bool> deleteAccount(User user) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.deleteAccount(user);
      state = state.copyWith(isLoading: false, clearError: true);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '계정 삭제 실패: ${e.message ?? e.code}',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '계정 삭제 중 오류가 발생했습니다: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final myPageActionProvider =
StateNotifierProvider<MyPageActionNotifier, MyPageActionState>((ref) {
  final repository = ref.watch(myPageRepositoryProvider);
  return MyPageActionNotifier(repository);
});