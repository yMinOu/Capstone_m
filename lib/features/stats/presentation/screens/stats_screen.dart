/// 학습 통계를 보여주는 화면.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/stats/data/models/stats_model.dart';
import 'package:nihongo/features/stats/presentation/providers/stats_providers.dart';
import 'package:nihongo/features/stats/presentation/widgets/stats_card_widget.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: statsAsync.when(
            data: (stats) => _StatsContent(stats: stats),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                '통계 데이터를 불러오지 못했어요.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final StatsModel stats;

  const _StatsContent({
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (stats.totalStudySeconds / 60).floor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              StatsCardWidget(
                title: '전체 학습 시간',
                value: '$totalMinutes',
                unit: '분',
              ),
              StatsCardWidget(
                title: '전체 학습 카드',
                value: '${stats.totalStudyCount}',
                unit: '개',
              ),
              StatsCardWidget(
                title: '오늘 학습한 카드',
                value: '${stats.learnedCount}',
                unit: '개',
              ),
              StatsCardWidget(
                title: '연속 학습일',
                value: '${stats.streakDays}',
                unit: '일',
              ),
            ],
          )
        ),
      ],
    );
  }
}