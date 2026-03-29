/// 통계 화면에서 사용할 학습 통계 모델.
class StatsChartItem {
  final String label;
  final int value;

  const StatsChartItem({
    required this.label,
    required this.value,
  });
}

class StatsModel {
  final int totalStudySeconds;
  final int totalStudyCount;
  final int learnedCount;
  final int streakDays;

  final List<StatsChartItem> dailyChart;
  final List<StatsChartItem> weeklyChart;
  final List<StatsChartItem> monthlyChart;

  const StatsModel({
    required this.totalStudySeconds,
    required this.totalStudyCount,
    required this.learnedCount,
    required this.streakDays,
    required this.dailyChart,
    required this.weeklyChart,
    required this.monthlyChart,
  });

  factory StatsModel.empty() {
    return const StatsModel(
      totalStudySeconds: 0,
      totalStudyCount: 0,
      learnedCount: 0,
      streakDays: 0,
      dailyChart: [],
      weeklyChart: [],
      monthlyChart: [],
    );
  }
}