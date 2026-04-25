/// 관리자 전용 - 사용자 의견 목록 화면.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/my_page/presentation/providers/feedback_provider.dart';

class FeedbackListScreen extends ConsumerWidget {
  const FeedbackListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(feedbackListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('의견 목록')),
      body: feedbackAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('등록된 의견이 없습니다.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 0, thickness: 0.5),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(
                  item.content,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  _formatDate(item.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                isThreeLine: false,
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
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
