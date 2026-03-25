import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/community/data/models/post_model.dart';
import 'package:nihongo/features/community/data/repositories/community_repository.dart';

final communityRepositoryProvider = Provider((ref) => CommunityRepository());

final communityPostsProvider = StreamProvider<List<PostModel>>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return repository.getPosts();
});
