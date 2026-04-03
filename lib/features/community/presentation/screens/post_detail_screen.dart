import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/core/constants/app_colors.dart';
import 'package:nihongo/features/community/data/models/post_model.dart';
import 'package:nihongo/features/community/data/models/comment_model.dart';
import 'package:nihongo/features/community/presentation/providers/community_provider.dart';
import 'package:nihongo/features/community/presentation/screens/community_write_screen.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  String? _replyToCommentId;
  String? _replyToAuthorName;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    // 키보드 닫기
    FocusScope.of(context).unfocus();

    try {
      if (_replyToCommentId != null) {
        // 답글 등록
        await ref.read(commentNotifierProvider.notifier).addReply(
              postId: widget.post.id,
              parentId: _replyToCommentId!,
              content: content,
            );
      } else {
        // 댓글 등록 시도
        await ref.read(commentNotifierProvider.notifier).addComment(widget.post.id, content);
      }

      // 성공 시 입력창 비우기 및 상태 초기화
      _commentController.clear();
      setState(() {
        _replyToCommentId = null;
        _replyToAuthorName = null;
      });

      // 성공 피드백 (선택 사항)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_replyToCommentId != null ? '답글이 등록되었습니다.' : '댓글이 등록되었습니다.'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // 실패 시 에러 핸들링
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _editComment(String postId, String commentId, String initialContent) async {
    final controller = TextEditingController(text: initialContent);
    
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('댓글 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '댓글을 입력하세요.',
          ),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('수정'),
          ),
        ],
      ),
    );

    if (newContent != null && newContent.isNotEmpty && newContent != initialContent) {
      try {
        await ref.read(commentNotifierProvider.notifier).updateComment(postId, commentId, newContent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('댓글이 수정되었습니다.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('수정 실패: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(communityRepositoryProvider);
    final currentUserId = repository.currentUserId;
    
    // 특정 포스트만 실시간으로 가져오기
    final postAsync = ref.watch(postProvider(widget.post.id));
    final post = postAsync.maybeWhen(
      data: (p) => p,
      orElse: () => widget.post,
    );
    
    final commentsAsync = ref.watch(commentsProvider(post.id));
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
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: const Icon(Icons.more_vert, color: AppColors.textBlack),
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  try {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityWriteScreen(post: post),
                      ),
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('화면 이동 중 오류가 발생했습니다: $e')),
                      );
                    }
                  }
                  break;
                  
                case 'delete':
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
                      await ref.read(postNotifierProvider.notifier).deletePost(post.id);
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
                  break;
                  
                case 'report':
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
                      await ref.read(postNotifierProvider.notifier).reportPost(post.id);
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
                  break;
              }
            },
            itemBuilder: (context) {
              final isAuthor = currentUserId != null && post.authorId == currentUserId;
              
              if (isAuthor) {
                return [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20, color: Colors.black87),
                        SizedBox(width: 8),
                        Text('수정하기'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('삭제하기', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              } else {
                return [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report_gmailerrorred, size: 20, color: Colors.black87),
                        SizedBox(width: 8),
                        Text('신고하기'),
                      ],
                    ),
                  ),
                ];
              }
            },
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
                              onTap: () => ref.read(postNotifierProvider.notifier).toggleLike(post.id),
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
                        return const SizedBox.shrink();
                      }
                      
                      // 부모 댓글만 필터링
                      final parentComments = comments.where((c) => c.parentId == null).toList();
                      
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: parentComments.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final comment = parentComments[index];
                          final isCommentAuthor = comment.authorId == currentUserId;
                          
                          // 해당 댓글의 답글들 필터링
                          final replies = comments.where((c) => c.parentId == comment.id).toList();
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 부모 댓글 표시
                              _buildCommentItem(post, comment, isCommentAuthor, currentUserId),
                              
                              // 답글들 표시 (들여쓰기 적용)
                              if (replies.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 30.0),
                                  child: Column(
                                    children: replies.map((reply) {
                                      final isReplyAuthor = reply.authorId == currentUserId;
                                      return _buildCommentItem(post, reply, isReplyAuthor, currentUserId, isReply: true);
                                    }).toList(),
                                  ),
                                ),
                            ],
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
          SafeArea(
            bottom: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_replyToCommentId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Text(
                          '${_replyToAuthorName}님에게 답글 남기는 중...',
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _replyToCommentId = null;
                              _replyToAuthorName = null;
                            });
                          },
                          child: const Icon(Icons.close, size: 16, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            hintText: _replyToCommentId != null ? '답글을 입력하세요.' : '댓글을 입력하세요.',
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
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(PostModel post, CommentModel comment, bool isCommentAuthor, String? currentUserId, {bool isReply = false}) {
    final isSelected = _replyToCommentId == comment.id;

    return GestureDetector(
      onTap: () {
        if (!isReply) {
          setState(() {
            if (_replyToCommentId == comment.id) {
              _replyToCommentId = null;
              _replyToAuthorName = null;
            } else {
              _replyToCommentId = comment.id;
              _replyToAuthorName = comment.authorName;
            }
          });
        }
      },
      child: Container(
        color: isSelected ? Colors.grey[200] : Colors.transparent,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isReply) ...[
                  const Icon(Icons.subdirectory_arrow_right, size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                ],
                Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                Text(_formatDateTime(comment.createdAt), style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await _editComment(post.id, comment.id, comment.content);
                    } else if (value == 'delete') {
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
                          await ref.read(commentNotifierProvider.notifier).deleteComment(post.id, comment.id);
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
                          await ref.read(commentNotifierProvider.notifier).reportComment(post.id, comment.id);
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
                    if (isCommentAuthor) ...[
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('수정'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('삭제', style: TextStyle(color: Colors.red)),
                      ),
                    ] else ...[
                      const PopupMenuItem(
                        value: 'report',
                        child: Text('신고하기'),
                      ),
                    ],
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
      ),
    );
  }
}
