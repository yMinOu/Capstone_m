/// 인증 관련 상태관리(Riverpod) 정의.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/auth/data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// 현재 로그인한 사용자 상태 스트림
final authUserProvider = StreamProvider<User?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

/// 로그인 진행 상태 및 에러 메시지를 담는 상태 클래스
class AuthActionState {
  const AuthActionState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  AuthActionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthActionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 로그인 요청 및 상태 변경을 처리하는 StateNotifier
class AuthActionNotifier extends StateNotifier<AuthActionState> {
  AuthActionNotifier(this._repository) : super(const AuthActionState());

  final AuthRepository _repository;

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.signInWithGoogle();

      state = state.copyWith(isLoading: false, clearError: true);
      return user != null;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '인증 오류: ${e.message ?? e.code}',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '로그인 중 오류가 발생했습니다: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authActionProvider =
StateNotifierProvider<AuthActionNotifier, AuthActionState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthActionNotifier(repository);
});