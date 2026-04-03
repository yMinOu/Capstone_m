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

final postProvider = StreamProvider.family<PostModel, String>((ref, postId) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getPost(postId);
});

final commentsProvider = StreamProvider.family<List<CommentModel>, String>((ref, postId) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getComments(postId);
});

final communitySearchQueryProvider = StateProvider<String>((ref) => '');

final communityTabProvider = StateProvider<int>((ref) => 0);

final filteredCommunityPostsProvider = Provider<AsyncValue<List<PostModel>>>((ref) {
  final postsAsync = ref.watch(communityPostsProvider);
  final searchQuery = ref.watch(communitySearchQueryProvider).toLowerCase();
  final selectedTabIndex = ref.watch(communityTabProvider);

  final categories = ['전체', '공부 이야기', '스터디 모집', '문제 질문', '잡담'];
  final selectedCategory = categories[selectedTabIndex];

  return postsAsync.whenData((posts) {
    var filteredPosts = posts;

    // 카테고리 필터링 (전체가 아닐 경우)
    if (selectedCategory != '전체') {
      filteredPosts = filteredPosts.where((post) => post.category == selectedCategory).toList();
    }

    // 검색어 필터링
    if (searchQuery.isNotEmpty) {
      filteredPosts = filteredPosts.where((post) {
        return post.title.toLowerCase().contains(searchQuery) ||
               post.content.toLowerCase().contains(searchQuery);
      }).toList();
    }

    return filteredPosts;
  });
});

// Post 관련 상태 관리
class PostNotifier extends StateNotifier<AsyncValue<void>> {
  final CommunityRepository _repository;

  PostNotifier(this._repository) : super(const AsyncValue.data(null));

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

  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    required String category,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updatePost(
        postId: postId,
        title: title,
        content: content,
        category: category,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> reportPost(String postId) async {
    try {
      await _repository.reportPost(postId);
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
}

// Comment 관련 상태 관리
class CommentNotifier extends StateNotifier<AsyncValue<void>> {
  final CommunityRepository _repository;

  CommentNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addComment(String postId, String content) async {
    try {
      await _repository.addComment(postId, content);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addReply({
    required String postId,
    required String parentId,
    required String content,
  }) async {
    try {
      await _repository.addReply(
        postId: postId,
        parentId: parentId,
        content: content,
      );
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

  Future<void> updateComment(String postId, String commentId, String content) async {
    try {
      await _repository.updateComment(
        postId: postId,
        commentId: commentId,
        content: content,
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> reportComment(String postId, String commentId) async {
    try {
      await _repository.reportComment(postId, commentId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final postNotifierProvider = StateNotifierProvider<PostNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return PostNotifier(repository);
});

final commentNotifierProvider = StateNotifierProvider<CommentNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return CommentNotifier(repository);
});
