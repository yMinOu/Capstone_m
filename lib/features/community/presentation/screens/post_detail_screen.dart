import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/core/constants/app_colors.dart';
import 'package:nihongo/features/community/data/models/post_model.dart';
import 'package:nihongo/features/community/presentation/providers/community_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    // 키보드 닫기
    FocusScope.of(context).unfocus();

    try {
      // 댓글 등록 시도
      await ref.read(communityNotifierProvider.notifier).addComment(widget.post.id, content);
      
      // 성공 시 입력창 비우기
      _commentController.clear();
      
      // 성공 피드백 (선택 사항)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 등록되었습니다.'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      // 실패 시 에러 핸들링
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 등록에 실패했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.post.id));
    final repository = ref.watch(communityRepositoryProvider);
    final currentUserId = repository.currentUserId;
    
    // 포스트의 실시간 상태를 위해 전체 포스트 목록에서 현재 포스트 찾기
    final postsAsync = ref.watch(communityPostsProvider);
    final post = postsAsync.whenOrNull(data: (posts) => posts.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post)) ?? widget.post;
    
    final isLiked = post.likes.contains(currentUserId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('게시글', style: TextStyle(color: AppColors.textBlack)),
        iconTheme: const IconThemeData(color: AppColors.textBlack),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) async {
              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('게시글 삭제'),
                    content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('삭제', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await ref.read(communityNotifierProvider.notifier).deletePost(post.id);
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('삭제 실패: $e')),
                      );
                    }
                  }
                }
              } else if (value == 'report') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('게시글 신고'),
                    content: const Text('이 게시글을 신고하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('신고', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await ref.read(communityNotifierProvider.notifier).reportPost(post.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('신고가 접수되었습니다.')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('신고 실패: $e')),
                      );
                    }
                  }
                }
              }
            },
            itemBuilder: (context) => [
              if (post.authorId == currentUserId)
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('삭제', style: TextStyle(color: Colors.red)),
                )
              else
                const PopupMenuItem(
                  value: 'report',
                  child: Text('신고하기'),
                ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 게시글 본문 영역
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary,
                              child: Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text('${post.category} · ${_formatDateTime(post.createdAt)}', 
                                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 12),
                        Text(post.content, style: const TextStyle(fontSize: 16, height: 1.5)),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => ref.read(communityNotifierProvider.notifier).toggleLike(post.id),
                              child: Row(
                                children: [
                                  Icon(isLiked ? Icons.favorite : Icons.favorite_border, 
                                    color: isLiked ? Colors.red : Colors.grey, size: 20),
                                  const SizedBox(width: 4),
                                  Text('${post.likes.length}', style: TextStyle(color: isLiked ? Colors.red : Colors.grey)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                            const SizedBox(width: 4),
                            Text('${post.commentCount}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
                  // 댓글 영역
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: const Text('댓글', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  commentsAsync.when(
                    data: (comments) {
                      if (comments.isEmpty) {
                        return const SizedBox.shrink(); // 댓글이 없으면 아무것도 표시 안 함
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final isCommentAuthor = comment.authorId == currentUserId;
                          
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const Spacer(),
                                    Text(_formatDateTime(comment.createdAt), style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                                    PopupMenuButton<String>(
                                      color: Colors.white,
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: const Text('댓글 삭제'),
                                              content: const Text('정말로 이 댓글을 삭제하시겠습니까?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('취소'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await ref.read(communityNotifierProvider.notifier).deleteComment(post.id, comment.id);
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('댓글이 삭제되었습니다.')),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('삭제 실패: $e')),
                                                );
                                              }
                                            }
                                          }
                                        } else if (value == 'report') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: const Text('댓글 신고'),
                                              content: const Text('이 댓글을 신고하시겠습니까?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('취소'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: const Text('신고', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await ref.read(communityNotifierProvider.notifier).reportComment(post.id, comment.id);
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('신고가 접수되었습니다.')),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('신고 실패: $e')),
                                                );
                                              }
                                            }
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        if (isCommentAuthor)
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('삭제', style: TextStyle(color: Colors.red)),
                                          )
                                        else
                                          const PopupMenuItem(
                                            value: 'report',
                                            child: Text('신고하기'),
                                          ),
                                      ],
                                      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textGrey),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(comment.content, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) {
                      debugPrint('Comments error: $e');
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text('댓글을 불러오지 못했습니다: $e', 
                          style: const TextStyle(color: Colors.red, fontSize: 12)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // 댓글 입력창
          Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              top: 10,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요.',
                      hintStyle: const TextStyle(fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _submitComment,
                  icon: const Icon(Icons.send, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
