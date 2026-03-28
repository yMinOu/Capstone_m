/// 통계 화면에서 사용할 Riverpod Provider 모음.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/stats/data/models/stats_model.dart';
import 'package:nihongo/features/stats/data/repositories/stats_repository.dart';
import 'package:nihongo/features/stats/presentation/widgets/stats_chart_widget.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

class StatsNotifier extends AsyncNotifier<StatsModel> {
  @override
  Future<StatsModel> build() async {
    final repository = ref.read(statsRepositoryProvider);
    return repository.fetchStats();
  }

  Future<void> refreshStats() async {
    final repository = ref.read(statsRepositoryProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return repository.fetchStats();
    });
  }

  Future<void> refreshStatsSilently() async {
    final repository = ref.read(statsRepositoryProvider);

    state = await AsyncValue.guard(() async {
      return repository.fetchStats();
    });
  }

  void updateLocal(StatsModel newStats) {
    state = AsyncData(newStats);
  }
}

final statsProvider =
AsyncNotifierProvider<StatsNotifier, StatsModel>(StatsNotifier.new);

final statsChartPeriodProvider =
StateProvider<StatsChartPeriod>((ref) => StatsChartPeriod.daily);