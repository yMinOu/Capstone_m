import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/my_page/data/models/notice_model.dart';
import 'package:nihongo/features/my_page/presentation/providers/notice_provider.dart';

class NoticeDetailScreen extends ConsumerWidget {
  final NoticeModel notice;
  final bool isAdmin;

  const NoticeDetailScreen({
    super.key,
    required this.notice,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('공지 삭제'),
                    content: const Text('이 공지사항을 삭제하시겠습니까?'),
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
                if (confirmed == true) {
                  await ref.read(noticeRepositoryProvider).deleteNotice(notice.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notice.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(notice.createdAt),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const Divider(height: 28),
            Text(
              notice.content,
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}
