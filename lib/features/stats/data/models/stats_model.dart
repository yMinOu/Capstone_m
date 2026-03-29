/// 통계 화면에서 사용할 학습 통계 모델.
class StatsChartItem {
  final String label;
  final int value;

  const StatsChartItem({
    required this.label,
    required this.value,
  });
}

class StatsWeakAreaItem {
  final String label;
  final int weaknessPercent;

  const StatsWeakAreaItem({
    required this.label,
    required this.weaknessPercent,
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

  final List<StatsWeakAreaItem> weakAreas;
  final String weakAreaMessage;

  const StatsModel({
    required this.totalStudySeconds,
    required this.totalStudyCount,
    required this.learnedCount,
    required this.streakDays,
    required this.dailyChart,
    required this.weeklyChart,
    required this.monthlyChart,
    required this.weakAreas,
    required this.weakAreaMessage,
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
      weakAreas: [
        StatsWeakAreaItem(label: '단어', weaknessPercent: 0),
        StatsWeakAreaItem(label: '한자', weaknessPercent: 0),
        StatsWeakAreaItem(label: '예문', weaknessPercent: 0),
        StatsWeakAreaItem(label: '가타카나', weaknessPercent: 0),
        StatsWeakAreaItem(label: '히라가나', weaknessPercent: 0),
        StatsWeakAreaItem(label: '스피킹', weaknessPercent: 0),
      ],
      weakAreaMessage: '아직 약한 영역 데이터가 없어요!',
    );
  }
}