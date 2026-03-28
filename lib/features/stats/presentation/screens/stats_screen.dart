/// 학습 통계를 보여주는 화면.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nihongo/features/stats/data/models/stats_model.dart';
import 'package:nihongo/features/stats/presentation/providers/stats_providers.dart';
import 'package:nihongo/features/stats/presentation/widgets/stats_card_widget.dart';
import 'package:nihongo/features/stats/presentation/widgets/stats_chart_widget.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  StatsChartPeriod _selectedPeriod = StatsChartPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: statsAsync.when(
            data: (stats) => _StatsContent(
              stats: stats,
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (period) {
                setState(() {
                  _selectedPeriod = period;
                });
              },
            ),
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
  final StatsChartPeriod selectedPeriod;
  final ValueChanged<StatsChartPeriod> onPeriodChanged;

  const _StatsContent({
    required this.stats,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final totalMinutes = (stats.totalStudySeconds / 60).floor();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
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
          ),
          const SizedBox(height: 20),
          StatsChartWidget(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: onPeriodChanged,
            dailyItems: stats.dailyChart,
            weeklyItems: stats.weeklyChart,
            monthlyItems: stats.monthlyChart,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}