import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/auth/presentation/providers/auth_provider.dart';
import 'package:nihongo/features/my_page/presentation/providers/notice_provider.dart';
import 'package:nihongo/features/my_page/presentation/screens/notice_detail_screen.dart';
import 'package:nihongo/features/my_page/presentation/screens/notice_write_screen.dart';

class NoticeListScreen extends ConsumerWidget {
  const NoticeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(noticeListProvider);
    final isAdminAsync = ref.watch(isAdminProvider);
    final isAdmin = isAdminAsync.valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NoticeWriteScreen()),
              ),
            ),
        ],
      ),
      body: noticesAsync.when(
        data: (notices) {
          if (notices.isEmpty) {
            return const Center(child: Text('등록된 공지사항이 없습니다.'));
          }
          return ListView.separated(
            itemCount: notices.length,
            separatorBuilder: (_, __) => const Divider(height: 0, thickness: 0.5),
            itemBuilder: (context, index) {
              final notice = notices[index];
              return ListTile(
                title: Text(
                  notice.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _formatDate(notice.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NoticeDetailScreen(notice: notice, isAdmin: isAdmin),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}
