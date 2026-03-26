import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/community/data/models/post_model.dart';
import 'package:nihongo/features/community/data/models/comment_model.dart';
import 'package:nihongo/features/community/data/repositories/community_repository.dart';
import 'package:nihongo/features/auth/presentation/providers/auth_provider.dart';

final communityRepositoryProvider = Provider((ref) => CommunityRepository());

final communityPostsProvider = StreamProvider<List<PostModel>>((ref) {
  final authState = ref.watch(authUserProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      final repository = ref.watch(communityRepositoryProvider);
      return repository.getPosts();
    },
    loading: () => const Stream.empty(),
    error: (_, __) => Stream.value([]),
  );
});

final commentsProvider = StreamProvider.family<List<CommentModel>, String>((ref, postId) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getComments(postId);
});

class CommunityNotifier extends StateNotifier<AsyncValue<void>> {
  final CommunityRepository _repository;

  CommunityNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createPost({
    required String title,
    required String content,
    required String category,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.createPost(
        title: title,
        content: content,
        category: category,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deletePost(String postId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deletePost(postId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      await _repository.toggleLike(postId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addComment(String postId, String content) async {
    try {
      await _repository.addComment(postId, content);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _repository.deleteComment(postId, commentId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final communityNotifierProvider = StateNotifierProvider<CommunityNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return CommunityNotifier(repository);
});
