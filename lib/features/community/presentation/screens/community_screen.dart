import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/core/constants/app_colors.dart';
import 'package:nihongo/features/community/presentation/providers/community_provider.dart';
import 'package:nihongo/features/community/presentation/screens/post_detail_screen.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(communityTabProvider);
    final categories = ['전체', '공부 이야기', '스터디 모집', '문제 질문', '잡담'];

    return Column(
      children: [
        // 상단 탭 버튼 (스크롤 가능하도록 함)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: List.generate(categories.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: _TabButton(
                  title: categories[index],
                  isSelected: selectedTab == index,
                  onTap: () => ref.read(communityTabProvider.notifier).state = index,
                ),
              );
            }),
          ),
        ),
        const Expanded(
          child: _CommunityListView(),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.textBlack : AppColors.textGrey.withOpacity(0.5),
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: AppColors.textBlack,
            ),
        ],
      ),
    );
  }
}

class _CommunityListView extends ConsumerWidget {
  const _CommunityListView();

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return '방금 전';
    if (difference.inHours < 1) return '${difference.inMinutes}분 전';
    if (difference.inDays < 1) return '${difference.inHours}시간 전';
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('게시글 삭제'),
        content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(postNotifierProvider.notifier).deletePost(postId);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(filteredCommunityPostsProvider);
    final repository = ref.watch(communityRepositoryProvider);
    final currentUserId = repository.currentUserId;

    return postsAsync.when(
      data: (posts) {
        if (posts.isEmpty) return const Center(child: Text('게시글이 없습니다.'));
        
        return ListView.separated(
          itemCount: posts.length,
          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
          itemBuilder: (context, index) {
            final post = posts[index];
            final isLiked = post.likes.contains(currentUserId);
            final isAuthor = post.authorId == currentUserId;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(post: post),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단 정보: 계정 이름 · 주제 · 시간
                    Row(
                      children: [
                        Text(
                          post.authorName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('·', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 4),
                        Text(
                          post.category,
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                        const SizedBox(width: 4),
                        const Text('·', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(post.createdAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                        const Spacer(),
                        if (isAuthor)
                          GestureDetector(
                            onTap: () => _showDeleteDialog(context, ref, post.id),
                            child: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 제목
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textBlack,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 내용
                    Text(
                      post.content,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // 하단: 공감 및 댓글 수
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => ref.read(postNotifierProvider.notifier).toggleLike(post.id),
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isLiked ? Colors.red : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${post.likes.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLiked ? Colors.red : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${post.commentCount}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('오류 발생: $err')),
    );
  }
}
