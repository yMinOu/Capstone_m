import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/auth/presentation/providers/auth_provider.dart';
import 'package:nihongo/features/my_page/data/models/notice_model.dart';
import 'package:nihongo/features/my_page/data/repositories/notice_repository.dart';

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepository();
});

final noticeListProvider = StreamProvider<List<NoticeModel>>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  return ref.watch(noticeRepositoryProvider).watchNotices();
});
